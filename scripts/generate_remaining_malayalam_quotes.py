#!/usr/bin/env python3
"""Generate only unrecorded Malayalam quote clips in one shared Aoede voice."""

import argparse
import importlib.util
import json
from pathlib import Path
import sys
import time
from typing import Any

ROOT = Path(__file__).resolve().parent.parent
OUTPUT_DIR = ROOT / "assets/audio/malayalam/shared_quotes"
QUOTE_CATALOG_PATH = OUTPUT_DIR / "quote_catalog.json"
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
    catalog = json.loads(QUOTE_CATALOG_PATH.read_text(encoding="utf-8"))
    if not isinstance(catalog, dict) or not isinstance(catalog.get("categories"), list):
        raise RuntimeError("Quote catalog has no categories")
    categories = catalog["categories"]

    remaining: list[dict[str, str]] = []
    seen_files: dict[str, str] = {}
    seen_ids: set[str] = set()
    for category in categories:
        if not isinstance(category, dict):
            raise RuntimeError("Invalid quote category in catalog")
        name = category.get("name")
        quotes = category.get("quotes")
        if not isinstance(name, str) or not isinstance(quotes, list):
            raise RuntimeError("Invalid quote category in catalog")
        for quote in quotes:
            if not isinstance(quote, dict):
                raise RuntimeError(f"Invalid quote in category {name!r}")
            quote_id = quote.get("id")
            text = quote.get("text")
            shared_asset = quote.get("shared_asset")
            if not isinstance(quote_id, str) or not isinstance(text, str):
                raise RuntimeError(f"Quote has no stable id or text in {name!r}")
            if quote_id in seen_ids:
                raise RuntimeError(f"Duplicate stable quote id: {quote_id}")
            seen_ids.add(quote_id)
            if shared_asset is None:
                continue
            if not isinstance(shared_asset, str) or not shared_asset:
                raise RuntimeError(f"Invalid shared audio id for quote {quote_id!r}")
            previous_text = seen_files.get(shared_asset)
            if previous_text is not None:
                if previous_text != text:
                    raise RuntimeError(
                        f"Shared audio id {shared_asset!r} is assigned to multiple quotes"
                    )
                continue
            seen_files[shared_asset] = text
            remaining.append({
                "id": quote_id,
                "category": name,
                "text": text,
                "filename": f"{shared_asset}.mp3",
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
