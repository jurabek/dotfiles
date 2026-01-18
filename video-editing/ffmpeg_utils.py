import json
import re
import subprocess


def get_fps(path):
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-select_streams', 'v:0',
         '-show_entries', 'stream=r_frame_rate',
         '-of', 'default=noprint_wrappers=1:nokey=1', path],
        capture_output=True, text=True
    )
    rate = result.stdout.strip()
    if '/' in rate:
        num, den = rate.split('/')
        return float(num) / float(den)
    return float(rate)


def get_duration(path):
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
         '-of', 'default=noprint_wrappers=1:nokey=1', path],
        capture_output=True, text=True
    )
    return float(result.stdout.strip())


def detect_silence(path, threshold_db, min_duration):
    """Returns list of (start, end) silence tuples"""
    filter_str = f"silencedetect=n={int(threshold_db)}dB:d={min_duration:.2f}"
    result = subprocess.run(
        ['ffmpeg', '-hide_banner', '-vn', '-i', path,
         '-af', filter_str, '-f', 'null', '-'],
        capture_output=True, text=True
    )

    silences = []
    start_re = re.compile(r'silence_start:\s*([\d.]+)')
    end_re = re.compile(r'silence_end:\s*([\d.]+)')

    current_start = None
    for line in result.stderr.split('\n'):
        match = start_re.search(line)
        if match:
            current_start = float(match.group(1))

        match = end_re.search(line)
        if match and current_start is not None:
            silences.append((current_start, float(match.group(1))))
            current_start = None

    return silences


def silences_to_clips(silences, duration, start_pad, end_pad):
    """Convert silence intervals to speaking clips"""
    clips = []

    if not silences:
        if duration > 0:
            clips.append((0, duration))
        return clips

    # Clip before first silence
    if silences[0][0] > 0:
        clips.append((0, silences[0][0] + end_pad))

    # Clips between silences
    for i in range(len(silences) - 1):
        start = silences[i][1] - start_pad
        end = silences[i + 1][0] + end_pad

        start = max(start, silences[i][1], 0)
        end = min(end, silences[i + 1][0])

        if end > start:
            clips.append((start, end))

    # Clip after last silence
    last_end = silences[-1][1]
    if last_end < duration:
        start = last_end - start_pad
        start = max(start, last_end)
        clips.append((start, duration))

    return clips


def encode_av1(input_path, output_path):
    """Encode to AV1 using VAAPI hardware acceleration"""
    cmd = [
        'ffmpeg',
        '-hwaccel', 'vaapi',
        '-hwaccel_device', '/dev/dri/renderD128',
        '-hwaccel_output_format', 'vaapi',
        '-i', input_path,
        '-c:v', 'av1_vaapi',
        '-b:v', '20M',
        '-c:a', 'pcm_s16le',
        '-y',
        output_path,
    ]
    subprocess.run(cmd, check=True)


def extract_bad_take_markers(path, fps):
    """Extract bad take chapter markers from video"""
    result = subprocess.run(
        ['ffprobe', '-i', path, '-show_chapters', '-v', 'quiet', '-print_format', 'json'],
        capture_output=True, text=True
    )
    data = json.loads(result.stdout) if result.stdout.strip() else {'chapters': []}
    markers = []
    for ch in data.get('chapters', []):
        if ch.get('tags', {}).get('title') == 'Bad Take':
            start_ms = int(ch.get('start', 0))
            frame = int((start_ms / 1000) * fps)
            markers.append(frame)
    return markers
