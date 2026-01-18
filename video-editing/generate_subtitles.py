#!/usr/bin/env python3
"""
Uzbek subtitle generator using local Whisper.
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

import whisper


def extract_audio(video_path: str, output_path: str) -> bool:
    """Extract audio from video using ffmpeg."""
    cmd = [
        "ffmpeg", "-y", "-i", video_path,
        "-vn", "-acodec", "pcm_s16le", "-ar", "16000", "-ac", "1",
        output_path,
    ]
    result = subprocess.run(cmd, capture_output=True)
    return result.returncode == 0


def format_srt_time(seconds: float) -> str:
    """Format seconds as SRT timestamp."""
    hours = int(seconds // 3600)
    mins = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    ms = int((seconds * 1000) % 1000)
    return f"{hours:02d}:{mins:02d}:{secs:02d},{ms:03d}"


def generate_srt(segments: list, output_path: str):
    """Generate SRT file from whisper segments."""
    with open(output_path, "w", encoding="utf-8") as f:
        for i, seg in enumerate(segments, 1):
            start = format_srt_time(seg["start"])
            end = format_srt_time(seg["end"])
            text = seg["text"].strip()

            f.write(f"{i}\n")
            f.write(f"{start} --> {end}\n")
            f.write(f"{text}\n\n")

    print(f"Generated: {output_path} ({len(segments)} entries)")


def main():
    parser = argparse.ArgumentParser(description="Generate Uzbek subtitles using local Whisper")
    parser.add_argument("input", help="Input video or audio file")
    parser.add_argument("--output", help="Output SRT path")
    parser.add_argument("--model", default="medium", help="Whisper model (tiny/base/small/medium/large)")
    parser.add_argument("--language", default="uz", help="Language code (default: uz)")
    args = parser.parse_args()

    input_path = os.path.abspath(args.input)
    if not os.path.exists(input_path):
        print(f"Error: File not found: {input_path}")
        sys.exit(1)

    base_name = Path(input_path).stem
    output_srt = args.output or f"{base_name}.srt"

    ext = Path(input_path).suffix.lower()
    audio_path = input_path
    temp_audio = None

    if ext in [".mp4", ".mkv", ".avi", ".mov", ".webm"]:
        print("Extracting audio...")
        temp_audio = f"/tmp/whisper_audio_{os.getpid()}.wav"
        if not extract_audio(input_path, temp_audio):
            print("Error: Failed to extract audio")
            sys.exit(1)
        audio_path = temp_audio

    print(f"Loading model: {args.model}")
    model = whisper.load_model(args.model)

    print(f"Transcribing: {input_path} (language: {args.language})")
    result = model.transcribe(audio_path, language=args.language)

    generate_srt(result["segments"], output_srt)

    if temp_audio and os.path.exists(temp_audio):
        os.remove(temp_audio)


if __name__ == "__main__":
    main()
