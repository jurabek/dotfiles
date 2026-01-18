#!/usr/bin/env python3
"""
Process latest recording and import to DaVinci Resolve.
Run from Resolve: Workspace > Scripts > process_latest
"""

import os
import shutil

resolve = app.GetResolve()  # noqa: F821

from config import (
    IMPORT_DIR,
    RECORDINGS_DIR,
    SILENCE_END_PAD,
    SILENCE_MIN_DURATION,
    SILENCE_START_PAD,
    SILENCE_THRESHOLD_DB,
)
from ffmpeg_utils import (
    detect_silence,
    encode_av1,
    extract_bad_take_markers,
    get_duration,
    get_fps,
    silences_to_clips,
)
from import_clips import import_video_with_clips


def find_latest_video(directory):
    """Find most recently modified video file"""
    video_exts = {".mp4", ".mkv", ".mov", ".avi", ".webm"}
    latest = None
    latest_time = 0

    for f in os.listdir(directory):
        if os.path.splitext(f)[1].lower() in video_exts:
            path = os.path.join(directory, f)
            mtime = os.path.getmtime(path)
            if mtime > latest_time:
                latest_time = mtime
                latest = path

    return latest


def main():
    # 1. Find latest video
    video_path = find_latest_video(RECORDINGS_DIR)
    if not video_path:
        print(f"No video found in {RECORDINGS_DIR}")
        return

    print(f"Processing: {video_path}")

    # 2. Get video info
    fps = get_fps(video_path)
    duration = get_duration(video_path)
    print(f"FPS: {fps:.2f}, Duration: {duration:.2f}s")

    # 3. Detect silence -> speaking clips
    silences = detect_silence(video_path, SILENCE_THRESHOLD_DB, SILENCE_MIN_DURATION)
    clips = silences_to_clips(silences, duration, SILENCE_START_PAD, SILENCE_END_PAD)
    print(f"Found {len(clips)} speaking clips")

    # 4. Extract bad take markers
    bad_take_markers = extract_bad_take_markers(video_path, fps)
    if bad_take_markers:
        print(f"Found {len(bad_take_markers)} bad take markers")

    # 5. Encode to AV1
    basename = os.path.basename(video_path)
    name, ext = os.path.splitext(basename)
    output_name = f"{name}_av1.mkv"
    output_path = os.path.join(IMPORT_DIR, output_name)

    os.makedirs(IMPORT_DIR, exist_ok=True)
    print(f"Encoding to: {output_path}")
    encode_av1(video_path, output_path)

    # 6. Import to timeline
    import_video_with_clips(resolve, output_path, clips, fps, bad_take_markers)


main()
