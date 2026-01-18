#!/usr/bin/env python3
"""
Uzbek subtitle generator using faster-whisper with ROCm GPU acceleration.
Optimized for AMD 780M (gfx1100).
"""

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

# Set for gfx1100 (780M) - MUST be before any torch/ctranslate2 imports
os.environ["HSA_OVERRIDE_GFX_VERSION"] = "11.0.0"
# Disable memory caching to prevent crashes on low VRAM
os.environ["PYTORCH_NO_HIP_MEMORY_CACHING"] = "1"

from faster_whisper import WhisperModel


def extract_audio(video_path: str, output_path: str) -> bool:
    """Extract audio from video using ffmpeg."""
    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        video_path,
        "-vn",
        "-acodec",
        "pcm_s16le",
        "-ar",
        "16000",
        "-ac",
        "1",
        output_path,
    ]
    # We suppress output unless there is an error
    result = subprocess.run(cmd, capture_output=True)
    return result.returncode == 0


def format_srt_time(seconds: float) -> str:
    """Format seconds as SRT timestamp (00:00:00,000)."""
    hours = int(seconds // 3600)
    mins = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    ms = int(round((seconds - int(seconds)) * 1000))
    if ms == 1000:  # Handle rounding edge case
        secs += 1
        ms = 0
    return f"{hours:02d}:{mins:02d}:{secs:02d},{ms:03d}"


def generate_srt(segments, output_path: str):
    """Generate SRT file from faster-whisper segments."""
    # Note: segments is a generator in faster-whisper
    with open(output_path, "w", encoding="utf-8") as f:
        for i, seg in enumerate(segments, 1):
            start = format_srt_time(seg.start)
            end = format_srt_time(seg.end)
            text = seg.text.strip()

            f.write(f"{i}\n")
            f.write(f"{start} --> {end}\n")
            f.write(f"{text}\n\n")

            # Print progress to console
            print(f"[{start}] {text}")

    print(f"\n✅ Done! Generated: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate Uzbek subtitles using faster-whisper (ROCm)"
    )
    parser.add_argument("input", help="Input video or audio file")
    parser.add_argument("--output", help="Output SRT path")
    parser.add_argument(
        "--model",
        default="large-v3",
        help="Model size: tiny, base, small, medium, large-v3",
    )
    parser.add_argument("--language", default="uz", help="Language code (default: uz)")
    # float16 is best for GPU, int8_float16 is even lighter on VRAM
    parser.add_argument(
        "--compute_type",
        default="float16",
        help="Compute type: float16, int8_float16, int8",
    )

    args = parser.parse_args()

    input_path = os.path.abspath(args.input)
    if not os.path.exists(input_path):
        print(f"Error: File not found: {input_path}")
        sys.exit(1)

    base_name = Path(input_path).stem
    output_srt = args.output or f"{base_name}.srt"

    # Audio Extraction Logic
    ext = Path(input_path).suffix.lower()
    audio_path = input_path
    temp_audio = None

    if ext in [".mp4", ".mkv", ".avi", ".mov", ".webm"]:
        print("--- Extracting audio ---")
        temp_audio = f"temp_whisper_audio_{os.getpid()}.wav"
        if not extract_audio(input_path, temp_audio):
            print("Error: Failed to extract audio")
            sys.exit(1)
        audio_path = temp_audio

    # Faster-Whisper Model Loading
    print(f"--- Loading model: {args.model} (Compute: {args.compute_type}) ---")
    try:
        # device="cuda" works for ROCm as long as torch-rocm is installed
        model = WhisperModel(args.model, device="cuda", compute_type=args.compute_type)
    except Exception as e:
        print(f"GPU failed: {e}. Falling back to CPU.")
        model = WhisperModel(args.model, device="cpu", compute_type="int8")

    print(f"--- Transcribing: {base_name} ---")
    start_time = time.time()

    # beam_size=5 is standard for quality; 1 is faster
    segments, info = model.transcribe(
        audio_path, language=args.language, beam_size=5, word_timestamps=False
    )

    print(
        f"Detected language '{info.language}' with probability {info.language_probability:.2f}"
    )

    # Process segments (this triggers the actual transcription)
    generate_srt(segments, output_srt)

    elapsed = time.time() - start_time
    print(f"Total processing time: {elapsed:.2f}s")

    # Cleanup
    if temp_audio and os.path.exists(temp_audio):
        os.remove(temp_audio)


if __name__ == "__main__":
    main()
