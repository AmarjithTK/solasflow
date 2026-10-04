#!/usr/bin/env python3
"""
Generate 4 Complete Sets of Malayalam Audio Clips for Solas Flow using OpenRouter Gemini TTS.

4 Distinct Voice Sets (2 Female, 2 Male):
- female_1: Aoede (Natural, breezy, pleasant female)
- female_2: Kore  (Clear, firm, composed female)
- male_1:   Puck  (Upbeat, clear, lively male)
- male_2:   Charon (Deep, calm, informative male)

Each set contains all 164 phrases (Hours 1-12, Minutes 1-59, Timer Remaining 1-60, Events 2, Quotes 31).
Total: 4 x 164 = 656 audio clips (~10 MB total).

Features:
- Individual, split API requests per clause/phrase.
- Atomic writes via temporary files so partial downloads are never saved.
- Seamless resume: already generated files are detected and skipped on re-run.
- Graceful Ctrl+C (KeyboardInterrupt) handling with progress report.
- Zero external dependencies: uses only Python 3 standard library.

Usage:
  # Export your OpenRouter API key:
  export OPENROUTER_API_KEY="sk-or-v1-..."

  # Test 1 sample quote across all 4 voices (audition all 4 voices):
  python scripts/generate_malayalam_audio.py --test-one

  # Generate all 4 complete voice sets (656 clips total):
  python scripts/generate_malayalam_audio.py

  # Generate a specific voice set only:
  python scripts/generate_malayalam_audio.py --voice female_1

  # Dry run (inspect manifest and file statuses without network calls):
  python scripts/generate_malayalam_audio.py --dry-run
"""

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
import wave
from typing import Any, Dict, List, Optional
DEFAULT_MODEL = "google/gemini-3.8-flash-tts"
DEFAULT_LANGUAGE = "ml"
DEFAULT_OUTPUT_DIR = "assets/audio/malayalam"
OPENROUTER_TTS_URL = "https://openrouter.ai/api/v1/audio/speech"

# The 4 distinct voice sets: 2 female, 2 male
VOICE_SETS = [
    {
        "id": "female_1",
        "voice": "Aoede",
        "gender": "female",
        "display_name": "Aoede (Female Natural)",
    },
    {
        "id": "female_2",
        "voice": "Kore",
        "gender": "female",
        "display_name": "Kore (Female Clear)",
    },
    {
        "id": "male_1",
        "voice": "Puck",
        "gender": "male",
        "display_name": "Puck (Male Upbeat)",
    },
    {
        "id": "male_2",
        "voice": "Charon",
        "gender": "male",
        "display_name": "Charon (Male Deep)",
    },
]

# Spelled-out Malayalam words for 1-60 to guarantee 100% natural pronunciation
# (Avoids AI reading digits like '1' as English 'One' or unnatural forms like 'ഒന്ന് മണി')
ML_NUMBERS: Dict[int, str] = {
    1: "ഒന്ന്", 2: "രണ്ട്", 3: "മൂന്ന്", 4: "നാല്", 5: "അഞ്ച്",
    6: "ആറ്", 7: "ഏഴ്", 8: "എട്ട്", 9: "ഒൻപത്", 10: "പത്ത്",
    11: "പതിനൊന്ന്", 12: "പന്ത്രണ്ട്", 13: "പതിമൂന്ന്", 14: "പതിനാല്", 15: "പതിനഞ്ച്",
    16: "പതിനാറ്", 17: "പതിനേഴ്", 18: "പതിനെട്ട്", 19: "പത്തൊൻപത്", 20: "ഇരുപത്",
    21: "ഇരുപത്തിയൊന്ന്", 22: "ഇരുപത്തിരണ്ട്", 23: "ഇരുപത്തിമൂന്ന്", 24: "ഇരുപത്തിനാല്", 25: "ഇരുപത്തിയഞ്ച്",
    26: "ഇരുപത്തിയാറ്", 27: "ഇരുപത്തിയേഴ്", 28: "ഇരുപത്തിയെട്ട്", 29: "ഇരുപത്തൊൻപത്", 30: "മുപ്പത്",
    31: "മുപ്പത്തിയൊന്ന്", 32: "മുപ്പത്തിരണ്ട്", 33: "മുപ്പത്തിമൂന്ന്", 34: "മുപ്പത്തിനാല്", 35: "മുപ്പത്തിയഞ്ച്",
    36: "മുപ്പത്തിയാറ്", 37: "മുപ്പത്തിയേഴ്", 38: "മുപ്പത്തിയെട്ട്", 39: "മുപ്പത്തൊൻപത്", 40: "നാൽപ്പത്",
    41: "നാൽപ്പത്തിയൊന്ന്", 42: "നാൽപ്പത്തിരണ്ട്", 43: "നാൽപ്പത്തിമൂന്ന്", 44: "നാൽപ്പത്തിനാല്", 45: "നാൽപ്പത്തിയഞ്ച്",
    46: "നാൽപ്പത്തിയാറ്", 47: "നാൽപ്പത്തിയേഴ്", 48: "നാൽപ്പത്തിയെട്ട്", 49: "നാൽപ്പത്തൊൻപത്", 50: "അമ്പത്",
    51: "അമ്പത്തിയൊന്ന്", 52: "അമ്പത്തിരണ്ട്", 53: "അമ്പത്തിമൂന്ന്", 54: "അമ്പത്തിനാല്", 55: "അമ്പത്തിയഞ്ച്",
    56: "അമ്പത്തിയാറ്", 57: "അമ്പത്തിയേഴ്", 58: "അമ്പത്തിയെട്ട്", 59: "അമ്പത്തൊൻപത്", 60: "അറുപത്",
}


def build_base_phrases() -> List[Dict[str, str]]:
    """Build the base 164 phrases (hours, minutes, timer, quotes)."""
    items: List[Dict[str, str]] = []

    # 1. Clock Hours (1 to 12)
    # Note: 1 o'clock in Malayalam is 'ഒരു മണി', not 'ഒന്ന് മണി'
    for h in range(1, 13):
        spoken = "ഒരു മണി." if h == 1 else f"{ML_NUMBERS[h]} മണി."
        items.append({
            "category": "clock_hours",
            "id": f"hour_{h:02d}",
            "text": spoken,
            "subpath": f"clock/hours/h_{h:02d}.mp3",
        })

    # 2. Clock Minutes (1 to 59)
    # Note: 1 minute is 'ഒരു മിനിറ്റ്', not 'ഒന്ന് മിനിറ്റ്'
    for m in range(1, 60):
        spoken = "ഒരു മിനിറ്റ്." if m == 1 else f"{ML_NUMBERS[m]} മിനിറ്റ്."
        items.append({
            "category": "clock_minutes",
            "id": f"min_{m:02d}",
            "text": spoken,
            "subpath": f"clock/minutes/m_{m:02d}.mp3",
        })

    # 3. Timer Remaining Minutes (1 to 60)
    for r in range(1, 61):
        spoken = "ഇനി ഒരു മിനിറ്റ്." if r == 1 else f"ഇനി {ML_NUMBERS[r]} മിനിറ്റ്."
        items.append({
            "category": "timer_remaining",
            "id": f"rem_{r:02d}",
            "text": spoken,
            "subpath": f"timer/rem_{r:02d}.mp3",
        })

    # 4. Timer Events
    items.append({
        "category": "timer_events",
        "id": "timer_finished",
        "text": "സമയം തീർന്നു.",
        "subpath": "timer/finished.mp3",
    })
    items.append({
        "category": "timer_events",
        "id": "timer_starting",
        "text": "അടുത്ത ടൈമർ ആരംഭിക്കുന്നു.",
        "subpath": "timer/starting.mp3",
    })

    # 5. Sound Test
    items.append({
        "category": "test",
        "id": "test_speech",
        "text": "ഇത് ശബ്ദ പരിശോധനയാണ്. നിങ്ങളുടെ ടൈമർ ആരംഭിക്കാൻ തയ്യാറാണ്.",
        "subpath": "test.mp3",
    })

    # 5. Motivational Quotes (31 quotes from MalayalamTtsService)
    quotes = [
        ("default", "നമുക്ക് മുന്നോട്ട് പോകാം, സമയം നന്നായി ഉപയോഗിക്കുക."),
        # Focus
        ("focus_1", "നിങ്ങളുടെ ശ്രദ്ധയാണ് ഏറ്റവും വലിയ ശക്തി."),
        ("focus_2", "ഒരു മണിക്കൂർ നല്ല ശ്രദ്ധയോടെ ചെയ്താൽ വലിയ മാറ്റമുണ്ടാകും."),
        ("focus_3", "നന്നായി ശ്രദ്ധിക്കുക, ഫലം തനിയെ വരും."),
        ("focus_4", "മറ്റു കാര്യങ്ങൾ മാറ്റി വെച്ച് ഇപ്പോൾ ചെയ്യുന്നതിൽ മാത്രം ശ്രദ്ധിക്കുക."),
        ("focus_5", "ഇപ്പോഴത്തെ കുറച്ചു ബുദ്ധിമുട്ട് പിന്നീട് സന്തോഷം നൽകും."),
        # Discipline
        ("discipline_1", "ചെറിയ കാര്യങ്ങൾ കൃത്യമായി ചെയ്യുന്നതാണ് യഥാർത്ഥ അച്ചടക്കം."),
        ("discipline_2", "വിജയം എന്നത് എന്നും ചെയ്യുന്ന ചെറിയ ശീലങ്ങളാണ്."),
        ("discipline_3", "ഇപ്പോഴത്തെ പരിശ്രമം നാളത്തെ ദിവസങ്ങൾ എളുപ്പമാക്കും."),
        ("discipline_4", "മടി കാണിക്കരുത്, വേണ്ടത് എന്താണോ അത് ചെയ്യുക."),
        ("discipline_5", "ശരിയായ ശീലങ്ങൾ നമ്മെ ലക്ഷ്യത്തിൽ എത്തിക്കും."),
        # Calm
        ("calm_1", "ദീർഘമായി ശ്വാസമെടുക്കൂ, ഈ ഒരു കാര്യത്തിൽ മാത്രം മനസ്സുറപ്പിക്കൂ."),
        ("calm_2", "തിരക്ക് പിടിക്കേണ്ട, ശാന്തമായി കാര്യങ്ങൾ ചെയ്യുക."),
        ("calm_3", "നമുക്ക് ഇനിയും സമയമുണ്ട്, സമാധാനത്തോടെ ചെയ്യാം."),
        ("calm_4", "ഓരോ നിമിഷവും പുതിയൊരു തുടക്കത്തിന് പറ്റിയതാണ്."),
        ("calm_5", "ശാന്തമായ മനസ്സോടെ ചെയ്യുന്ന കാര്യങ്ങളെല്ലാം മികച്ചതായിരിക്കും."),
        # Positivity
        ("positivity_1", "നല്ലത് ചിന്തിക്കുക, നല്ലത് മാത്രം സംഭവിക്കും."),
        ("positivity_2", "ഇന്നത്തെ പരിശ്രമം നാളത്തെ വലിയ വിജയമായി മാറും."),
        ("positivity_3", "ചെറിയ കാൽവെപ്പുകളും നമ്മെ മുന്നോട്ട് നയിക്കുന്നു."),
        ("positivity_4", "നമ്മൾ തുടങ്ങുന്ന സമയമാണ് ഏറ്റവും നല്ല സമയം."),
        ("positivity_5", "നല്ലൊരു മനസ്സുണ്ടെങ്കിൽ ഏതു വലിയ കാര്യവും എളുപ്പത്തിൽ തീർക്കാം."),
        # Historic Figures
        ("historic_1", "നഷ്ടപ്പെട്ട സമയം ഒരിക്കലും തിരികെ കിട്ടില്ല."),
        ("historic_2", "നമ്മൾ സ്ഥിരമായി ചെയ്യുന്ന കാര്യങ്ങളാണ് നമ്മുടെ സ്വഭാവം."),
        ("historic_3", "സമയം ശരിയായി വിനിയോഗിക്കുന്നവർക്ക് അത് എപ്പോഴും ധാരാളമായിരിക്കും."),
        ("historic_4", "ഒന്നും ചെയ്യാതെ ഇരുന്നാൽ ഒന്നും നടക്കില്ല."),
        ("historic_5", "സൂര്യപ്രകാശം പോലെ ഒരിടത്ത് മാത്രം ശ്രദ്ധ കേന്ദ്രീകരിച്ചാൽ ഏതു കാര്യവും നടക്കും."),
        # General
        ("general_1", "ഈ സമയം ബുദ്ധിപൂർവ്വം ഉപയോഗിക്കുക."),
        ("general_2", "സ്ഥിരമായുള്ള ചെറിയ മാറ്റങ്ങൾ വലിയ ലക്ഷ്യങ്ങളിൽ എത്തിക്കും."),
        ("general_3", "തിരിച്ചുകിട്ടാത്ത വലിയൊരു സമ്പത്താണ് സമയം."),
        ("general_4", "നമുക്ക് ചെയ്യാൻ പറ്റുന്നത് ഇപ്പോൾ തന്നെ ചെയ്യുക."),
        ("general_5", "ഇന്നത്തെ നമ്മുടെ പ്രവർത്തിയാണ് നമ്മുടെ ഭാവിയെ തീരുമാനിക്കുന്നത്."),
    ]

    for qid, qtext in quotes:
        items.append({
            "category": "quotes",
            "id": f"quote_{qid}",
            "text": qtext,
            "subpath": f"quotes/{qid}.mp3",
        })

    return items


def build_full_manifest(selected_voices: List[Dict[str, str]]) -> List[Dict[str, Any]]:
    """Generate the full matrix of selected voices x base phrases."""
    base_phrases = build_base_phrases()
    full_manifest: List[Dict[str, Any]] = []

    for v in selected_voices:
        for p in base_phrases:
            full_manifest.append({
                "voice_id": v["id"],
                "voice_name": v["voice"],
                "voice_display": v["display_name"],
                "gender": v["gender"],
                "category": p["category"],
                "id": p["id"],
                "text": p["text"],
                "rel_path": f"{v['id']}/{p['subpath']}",
            })

    return full_manifest

def resolve_api_key(cli_arg: Optional[str] = None) -> Optional[str]:
    """Resolve OpenRouter API key from CLI arg, environment, or ~/.zshrc without exposing secrets."""
    if cli_arg:
        return cli_arg.strip()

    for env_var in ["OPENROUTER_API_KEY", "OPENROUTER_KEY", "OPEN_ROUTER_API_KEY"]:
        val = os.environ.get(env_var)
        if val:
            return val.strip()

    # Fallback to shell rc files (~/.zshrc, ~/.bashrc, ~/.profile)
    for rc_name in [".zshrc", ".bashrc", ".profile"]:
        rc_path = os.path.expanduser(f"~/{rc_name}")
        if os.path.isfile(rc_path):
            try:
                with open(rc_path, "r", encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        line = line.strip()
                        m = re.match(r'^export\s+([A-Za-z0-9_]*OPENROUTER[A-Za-z0-9_]*)=["\']?(.*?)["\']?$', line)
                        if m:
                            val = m.group(2).strip().strip("'\"")
                            if val:
                                return val
            except Exception:
                pass
    return None


def synthesize_speech(
    api_key: str,
    text: str,
    model: str,
    voice: str,
    language: str = DEFAULT_LANGUAGE,
    max_retries: int = 5,
) -> bytes:
    """Send an individual TTS request to OpenRouter and return raw MP3 bytes."""
    payload: Dict[str, Any] = {
        "model": model,
        "input": text,
        "voice": voice,
        "response_format": "pcm",
    }
    if language:
        payload["language"] = language

    def _make_req(p: Dict[str, Any]) -> urllib.request.Request:
        data = json.dumps(p).encode("utf-8")
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://github.com/solasflow",
            "X-Title": "SolasFlow Malayalam Speech Generator",
        }
        return urllib.request.Request(OPENROUTER_TTS_URL, data=data, headers=headers, method="POST")

    req = _make_req(payload)

    for attempt in range(1, max_retries + 1):
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                status = resp.status
                if status == 200:
                    audio_bytes = resp.read()
                    if len(audio_bytes) < 100:
                        raise ValueError(f"Received unexpectedly small audio payload: {len(audio_bytes)} bytes")
                    return audio_bytes
                else:
                    raise urllib.error.HTTPError(
                        req.full_url, status, f"Unexpected HTTP status {status}", resp.headers, None
                    )
        except urllib.error.HTTPError as e:
            error_body = ""
            try:
                error_body = e.read().decode("utf-8", errors="replace")
            except Exception:
                pass

            # If 400 Bad Request happens because 'language' field is not supported in OpenRouter's schema,
            # automatically fallback to payload without 'language'
            if e.code == 400 and "language" in payload:
                payload.pop("language", None)
                req = _make_req(payload)
                continue

            # Authentication / Quota errors: don't retry, exit immediately
            if e.code in (401, 402, 403):
                print(f"\n[FATAL] HTTP {e.code}: {error_body or e.reason}")
                if e.code == 401:
                    print("Check your OPENROUTER_API_KEY.")
                elif e.code == 402:
                    print("Insufficient credits on OpenRouter. Please top up at https://openrouter.ai/credits")
                sys.exit(1)

            # Rate limit or server error: backoff and retry
            if e.code in (429, 500, 502, 503, 524, 529):
                wait_time = (2 ** attempt) + (attempt * 0.5)
                print(f" [HTTP {e.code}, retry {attempt}/{max_retries} in {wait_time:.1f}s...]", end="", flush=True)
                time.sleep(wait_time)
                continue

            print(f"\n[ERROR] HTTP {e.code}: {error_body or e.reason}")
            raise
        except (urllib.error.URLError, TimeoutError, ConnectionResetError) as e:
            if attempt < max_retries:
                wait_time = (2 ** attempt)
                print(f" [Network error: {e}, retry {attempt}/{max_retries} in {wait_time:.1f}s...]", end="", flush=True)
                time.sleep(wait_time)
                continue
            raise

    raise RuntimeError(f"Failed to synthesize after {max_retries} retries.")

def save_pcm_as_audio(pcm_data: bytes, dest_path: str, tmp_prefix: str) -> None:
    """Package raw 24kHz 16-bit mono PCM into WAV and encode to MP3 if ffmpeg is available."""
    tmp_wav = tmp_prefix + ".wav"
    with wave.open(tmp_wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)      # 16-bit
        w.setframerate(24000)  # 24 kHz
        w.writeframes(pcm_data)

    has_ffmpeg = shutil.which("ffmpeg") is not None
    if dest_path.endswith(".mp3") and has_ffmpeg:
        tmp_mp3 = tmp_prefix + ".mp3"
        try:
            subprocess.run(
                ["ffmpeg", "-y", "-i", tmp_wav, "-codec:a", "libmp3lame", "-b:a", "64k", tmp_mp3],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            os.replace(tmp_mp3, dest_path)
        finally:
            if os.path.exists(tmp_wav):
                os.remove(tmp_wav)
            if os.path.exists(tmp_mp3):
                os.remove(tmp_mp3)
    else:
        # Direct WAV or ffmpeg not found
        final_wav = dest_path if dest_path.endswith(".wav") else dest_path.replace(".mp3", ".wav")
        os.replace(tmp_wav, final_wav)


def main():
    parser = argparse.ArgumentParser(
        description="Generate 4 Complete Sets of Malayalam Audio Clips for Solas Flow (2 Female, 2 Male)."
    )
    parser.add_argument(
        "--api-key",
        default=None,
        help="OpenRouter API key (auto-detected from environment or ~/.zshrc if omitted)",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"OpenRouter TTS model (default: {DEFAULT_MODEL})",
    )
    parser.add_argument(
        "--voice",
        default="all",
        choices=["all", "female_1", "female_2", "male_1", "male_2"],
        help="Voice set to generate: all (default, all 4 sets), female_1 (Aoede), female_2 (Kore), male_1 (Puck), male_2 (Charon)",
    )
    parser.add_argument(
        "--language",
        default=DEFAULT_LANGUAGE,
        help=f"TTS language code in request payload (default: {DEFAULT_LANGUAGE})",
    )
    parser.add_argument(
        "--output-dir",
        default=DEFAULT_OUTPUT_DIR,
        help=f"Output root directory (default: {DEFAULT_OUTPUT_DIR})",
    )
    parser.add_argument(
        "--concurrency",
        type=int,
        default=3,
        help="Number of concurrent workers (default: 3)",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.1,
        help="Polite delay in seconds between requests per worker (default: 0.1s)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List all clips and paths without sending any network requests",
    )
    parser.add_argument(
        "--test-one",
        action="store_true",
        help="Synthesize 1 sample quote for each of the 4 voices (4 clips total) to audition all voices",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Re-generate all files even if they already exist on disk",
    )
    args = parser.parse_args()

    # Filter selected voices
    if args.voice == "all":
        selected_voices = VOICE_SETS
    else:
        selected_voices = [v for v in VOICE_SETS if v["id"] == args.voice]

    manifest = build_full_manifest(selected_voices)

    if args.test_one:
        # Pick 1 sample quote for each selected voice
        manifest = [item for item in manifest if item["id"] == "quote_default"]
        print(f"=== TEST RUN: 1 sample quote across {len(selected_voices)} voice(s) ===")

    total_clips = len(manifest)

    if args.dry_run:
        print(f"=== DRY RUN: {total_clips} clips across {len(selected_voices)} voice set(s) ===")
        for i, item in enumerate(manifest, 1):
            out_file = os.path.join(args.output_dir, item["rel_path"])
            status = "EXISTS" if (os.path.exists(out_file) and os.path.getsize(out_file) > 100) else "PENDING"
            print(f"[{i:03d}/{total_clips}] [{status:7s}] [{item['voice_display']}] {out_file} -> {item['text']}")
        return

    api_key = resolve_api_key(args.api_key)
    if not api_key:
        print("[ERROR] OpenRouter API key could not be found.")
        print("Please ensure OPENROUTER_API_KEY is exported in your environment or ~/.zshrc.")
        sys.exit(1)

    print(f"=== Solas Flow 4-Voice Malayalam Speech Generator ===")
    print(f"Model:       {args.model}")
    print(f"Voices ({len(selected_voices)}):  {', '.join(v['display_name'] for v in selected_voices)}")
    print(f"API Key:     Loaded from environment/zshrc (...{api_key[-4:]})")
    print(f"Output Root: {os.path.abspath(args.output_dir)}")
    print(f"Total Clips: {total_clips}")
    print("=" * 56)

    print_lock = threading.Lock()
    completed_count = 0
    skipped_count = 0
    active_tmp_files: List[str] = []

    def handle_interrupt(signum, frame):
        with print_lock:
            print("\n\n[INTERRUPTED] Operation cancelled by user (Ctrl+C).")
            for tmp in active_tmp_files:
                for ext in ["", ".tmp", ".wav", ".mp3"]:
                    p = tmp + ext
                    if os.path.exists(p):
                        try:
                            os.remove(p)
                        except Exception:
                            pass
            print("Progress was saved safely. Re-run anytime to resume where you left off.")
        sys.exit(130)

    signal.signal(signal.SIGINT, handle_interrupt)

    def process_item(entry):
        nonlocal completed_count, skipped_count
        idx, item = entry
        dest_path = os.path.join(args.output_dir, item["rel_path"])
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)

        # Resume check
        if not args.force and os.path.exists(dest_path) and os.path.getsize(dest_path) > 100:
            with print_lock:
                skipped_count += 1
                print(f"[{idx:03d}/{total_clips}] [EXISTS] [{item['voice_id']}] {item['rel_path']}")
            return

        tmp_prefix = dest_path + ".tmp"
        with print_lock:
            active_tmp_files.append(tmp_prefix)
            print(
                f"[{idx:03d}/{total_clips}] [{item['voice_id']}:{item['voice_name']}] {item['rel_path']} ('{item['text']}')...",
                flush=True,
            )

        try:
            start_t = time.time()
            pcm_data = synthesize_speech(
                api_key=api_key,
                text=item["text"],
                model=args.model,
                voice=item["voice_name"],
                language=args.language,
            )

            save_pcm_as_audio(pcm_data, dest_path, tmp_prefix)
            duration = time.time() - start_t
            file_size_kb = os.path.getsize(dest_path) // 1024

            with print_lock:
                completed_count += 1
                if tmp_prefix in active_tmp_files:
                    active_tmp_files.remove(tmp_prefix)
                print(f"[{idx:03d}/{total_clips}] [DONE] {item['rel_path']} ({file_size_kb} KB in {duration:.2f}s)")

        except Exception as e:
            for ext in ["", ".tmp", ".wav", ".mp3"]:
                p = tmp_prefix + ext
                if os.path.exists(p):
                    try:
                        os.remove(p)
                    except Exception:
                        pass
            with print_lock:
                print(f"[{idx:03d}/{total_clips}] [FAILED] {item['rel_path']}: {e}")
            raise

        if args.delay > 0:
            time.sleep(args.delay)

    entries = list(enumerate(manifest, 1))
    max_workers = max(1, args.concurrency)

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(process_item, entry) for entry in entries]
        for future in as_completed(futures):
            try:
                future.result()
            except Exception:
                executor.shutdown(wait=False, cancel_futures=True)
                raise

    print("\n" + "=" * 56)
    print(f"Finished! Newly generated: {completed_count}, Already existed (skipped): {skipped_count}")
    print(f"All clips ready in: {os.path.abspath(args.output_dir)}")
    print_cost_summary(args.output_dir)


def print_cost_summary(output_dir: str):
    """Print total files, duration, disk size, and accurate OpenRouter cost estimate."""
    total_size = 0
    count = 0
    voice_counts: Dict[str, int] = {}

    for root, _, files in os.walk(output_dir):
        for f in files:
            if f.endswith(".mp3"):
                path = os.path.join(root, f)
                total_size += os.path.getsize(path)
                count += 1
                rel = os.path.relpath(path, output_dir)
                voice = rel.split(os.sep)[0]
                voice_counts[voice] = voice_counts.get(voice, 0) + 1

    if count == 0:
        return

    # MP3s are encoded at 64 kbps (8,000 bytes/sec)
    est_duration_sec = total_size / 8000.0
    audio_tokens = est_duration_sec * 25.0
    audio_cost = (audio_tokens / 1_000_000.0) * 9.00
    input_cost = (count * 10 / 1_000_000.0) * 0.50
    total_cost = audio_cost + input_cost
    inr_cost = total_cost * 87.0

    print("\n" + "=" * 56)
    print("=== Malayalam Speech Generation Cost Summary ===")
    print(f"Total Audio Clips: {count} files")
    for v, c in sorted(voice_counts.items()):
        print(f"  • {v:10s}:     {c} clips")
    print(f"Total Disk Size:   {total_size / (1024 * 1024):.2f} MB")
    print(f"Total Audio Time:  ~{int(est_duration_sec // 60)}m {int(est_duration_sec % 60)}s ({est_duration_sec:.1f} seconds)")
    print(f"Audio Tokens:      ~{int(audio_tokens):,} tokens (@ 25 tokens/sec)")
    print(f"Estimated Cost:    ${total_cost:.3f} USD (~₹{inr_cost:.2f} INR)")
    print("=" * 56)

if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        sys.stderr.close()
