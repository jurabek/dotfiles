#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DR_SCRIPTS="$HOME/.local/share/DaVinciResolve/Fusion/Scripts/Utility"

mkdir -p "$DR_SCRIPTS"

ln -sf "$SCRIPT_DIR/process_latest.py" "$DR_SCRIPTS/process_latest.py"
ln -sf "$SCRIPT_DIR/config.py" "$DR_SCRIPTS/config.py"
ln -sf "$SCRIPT_DIR/ffmpeg_utils.py" "$DR_SCRIPTS/ffmpeg_utils.py"
ln -sf "$SCRIPT_DIR/import_clips.py" "$DR_SCRIPTS/import_clips.py"

echo "Linked to $DR_SCRIPTS"
