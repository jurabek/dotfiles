import os
from config import BAD_TAKE_PADDING, BAD_TAKE_MAX_DISTANCE, SILENCE_MODE


def is_bad_take(clip, bad_take_markers, index, clips, fps):
    """Returns: 'good', 'maybe-bad', or 'definitely-bad'"""
    start_frame, end_frame = clip['in'], clip['out']

    for m in bad_take_markers:
        if start_frame <= m <= end_frame:
            return 'definitely-bad'

    padding_frames = int(BAD_TAKE_PADDING * fps)
    max_distance_frames = int(BAD_TAKE_MAX_DISTANCE * fps)

    for m in bad_take_markers:
        if end_frame < m <= end_frame + padding_frames:
            if m <= end_frame + max_distance_frames:
                return 'definitely-bad'

    if index == len(clips) - 1:
        for m in bad_take_markers:
            if start_frame < m <= end_frame + max_distance_frames:
                return 'maybe-bad'
        return 'good'

    next_clip = clips[index + 1]
    for m in bad_take_markers:
        if start_frame < m < next_clip['in']:
            if m <= end_frame + max_distance_frames:
                return 'maybe-bad'

    return 'good'


def get_silence_segments(speaking_clips, total_frames):
    """Invert speaking clips to get silence segments"""
    silences = []
    prev_end = 0
    for clip in speaking_clips:
        if clip['in'] > prev_end:
            silences.append({'in': prev_end, 'out': clip['in']})
        prev_end = clip['out']
    if prev_end < total_frames:
        silences.append({'in': prev_end, 'out': total_frames})
    return silences


def import_video_with_clips(resolve, video_path, clips, fps, bad_take_markers):
    """
    Import video into DaVinci Resolve and create timeline with colored clips.

    clips: list of (start_sec, end_sec) tuples
    bad_take_markers: list of frame numbers
    """
    project_manager = resolve.GetProjectManager()
    project = project_manager.GetCurrentProject()

    if not project:
        from datetime import datetime
        name = f"Edit_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        project = project_manager.CreateProject(name)
        print(f"Created project: {name}")

    media_pool = project.GetMediaPool()
    media_storage = resolve.GetMediaStorage()

    print(f"Importing: {video_path}")
    imported = media_storage.AddItemListToMediaPool(video_path)

    if not imported:
        print("Error: Could not import video")
        return False

    source_clip = imported[0]

    # Convert time-based clips to frame-based
    speaking_clips = [{'in': int(s * fps), 'out': int(e * fps)} for s, e in clips]

    # Get total frames from duration
    total_frames = speaking_clips[-1]['out'] if speaking_clips else 0

    # Calculate silence segments
    silence_segments = get_silence_segments(speaking_clips, total_frames)
    print(f"Found {len(speaking_clips)} speaking, {len(silence_segments)} silence segments")

    timeline_name = os.path.splitext(os.path.basename(video_path))[0]
    timeline = media_pool.CreateEmptyTimeline(timeline_name)

    if not timeline:
        print("Error: Could not create timeline")
        return False

    # Merge speaking and silence into sorted list
    all_segments = []
    for i, clip in enumerate(speaking_clips):
        bad_status = is_bad_take(clip, bad_take_markers, i, speaking_clips, fps)
        seg_type = 'bad' if bad_status != 'good' else 'speaking'
        all_segments.append({'in': clip['in'], 'out': clip['out'], 'type': seg_type})

    if SILENCE_MODE == "include":
        for seg in silence_segments:
            all_segments.append({'in': seg['in'], 'out': seg['out'], 'type': 'silence'})

    all_segments.sort(key=lambda x: x['in'])

    # Add segments with colors
    silence_count = 0
    bad_count = 0
    for seg in all_segments:
        items = media_pool.AppendToTimeline([{
            "mediaPoolItem": source_clip,
            "startFrame": seg['in'],
            "endFrame": seg['out']
        }])
        if items and len(items) > 0:
            item = items[0]
            if seg['type'] == 'silence':
                item.SetClipColor("Orange")
                silence_count += 1
            elif seg['type'] == 'bad':
                item.SetClipColor("Brown")
                bad_count += 1

    print(f"Timeline: {len(all_segments)} clips (silence_mode={SILENCE_MODE})")
    print(f"  {len(speaking_clips) - bad_count} speaking (default)")
    if SILENCE_MODE == "include":
        print(f"  {silence_count} silence (orange)")
    print(f"  {bad_count} bad takes (brown)")

    project_manager.SaveProject()
    print(f"Done: {timeline_name}")
    return True
