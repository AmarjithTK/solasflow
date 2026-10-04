#!/usr/bin/env python3
"""Generate only unrecorded Malayalam quote clips in one shared Aoede voice."""

import argparse
import importlib.util
from pathlib import Path
import re
import sys
import time
from typing import Any

ROOT = Path(__file__).resolve().parent.parent
SERVICE_PATH = ROOT / "lib/services/malayalam_tts_service.dart"
OUTPUT_DIR = ROOT / "assets/audio/malayalam/shared_quotes"
VOICE = "Aoede"


def load_existing_generator() -> Any:
    path = ROOT / "scripts/generate_malayalam_audio.py"
    spec = importlib.util.spec_from_file_location("malayalam_audio_generator", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load existing audio helper: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def read_remaining_quotes() -> list[dict[str, str]]:
    source = SERVICE_PATH.read_text(encoding="utf-8")
    catalog_start = source.index("List<String> quotesForCategory(String category)")
    catalog_end = source.index("static const Map<String, String> _quoteFileMap", catalog_start)
    catalog = source[catalog_start:catalog_end]
    recorded_section_start = catalog_end
    recorded_section_end = source.index("  };", recorded_section_start)
    recorded_section = source[recorded_section_start:recorded_section_end]
    recorded = {
        match.group(1)
        for match in re.finditer(r"^\s*'([^']+)':\s*'[^']+',\s*$", recorded_section, re.MULTILINE)
    }

    categories: list[tuple[str, str]] = []
    for match in re.finditer(r"case '([^']+)':\s*return const \[(.*?)\];", catalog, re.DOTALL):
        categories.append((match.group(1), match.group(2)))
    default_match = re.search(r"default:\s*return const \[(.*?)\];", catalog, re.DOTALL)
    if default_match is None:
        raise RuntimeError("Could not find the default Malayalam quote list")
    categories.append(("General", default_match.group(1)))

    remaining: list[dict[str, str]] = []
    seen: set[str] = set()
    for category, body in categories:
        slug = category.lower().replace(" ", "_")
        quotes = re.findall(r"^\s*'([^']*)',\s*$", body, re.MULTILINE)
        if not quotes:
            raise RuntimeError(f"No quote strings parsed from category {category!r}")
        for index, text in enumerate(quotes, start=1):
            if text in recorded or text in seen:
                continue
            seen.add(text)
            remaining.append({
                "category": category,
                "text": text,
                "filename": f"{slug}_{index:02d}.mp3",
            })
    return remaining


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate only missing Malayalam quote clips, with one Aoede voice recording per phrase."
    )
    parser.add_argument("--dry-run", action="store_true", help="List missing quote clips without API calls")
    parser.add_argument("--model", default="google/gemini-3.8-flash-tts")
    parser.add_argument("--output-dir", type=Path, default=OUTPUT_DIR)
    args = parser.parse_args()

    generator = load_existing_generator()
    manifest = read_remaining_quotes()
    pending = []
    existing = 0
    for item in manifest:
        output = args.output_dir / item["filename"]
        if output.is_file() and output.stat().st_size > 100:
            existing += 1
        else:
            pending.append(item)

    print(f"Malayalam-only quotes: {len(manifest)} missing phrases; voice: {VOICE}")
    print(f"Output: {args.output_dir}")
    print(f"Already generated: {existing}; pending: {len(pending)}")
    if args.dry_run:
        for item in pending:
            print(f"[{item['category']}] {item['filename']}: {item['text']}")
        return 0
    if not pending:
        print("Nothing to generate.")
        return 0

    api_key = generator.resolve_api_key()
    if not api_key:
        print("OPENROUTER_API_KEY was not found in the environment or shell rc files.", file=sys.stderr)
        return 1

    args.output_dir.mkdir(parents=True, exist_ok=True)
    completed = 0
    for index, item in enumerate(pending, start=1):
        destination = args.output_dir / item["filename"]
        temporary = str(destination) + ".tmp"
        print(f"[{index}/{len(pending)}] {item['filename']} ({item['category']})", flush=True)
        try:
            pcm = generator.synthesize_speech(
                api_key=api_key,
                text=item["text"],
                model=args.model,
                voice=VOICE,
                language="ml",
            )
            generator.save_pcm_as_audio(pcm, str(destination), temporary)
            if not destination.is_file() or destination.stat().st_size <= 100:
                raise RuntimeError("Audio conversion produced no valid output file")
            completed += 1
            print(f"  saved {destination.stat().st_size} bytes", flush=True)
        except Exception:
            for suffix in ("", ".tmp", ".wav", ".mp3"):
                path = Path(temporary + suffix)
                if path.exists():
                    path.unlink()
            raise
        time.sleep(0.15)

    total_bytes = sum((args.output_dir / item["filename"]).stat().st_size for item in manifest)
    print(f"Generated {completed}; total shared Malayalam quote clips: {len(manifest)} ({total_bytes / 1024:.1f} KiB).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
