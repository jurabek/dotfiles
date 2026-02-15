#!/bin/bash
set -euo pipefail

# GPU tools
distrobox-export --bin /usr/bin/rocminfo --export-path ~/.local/bin
distrobox-export --bin /usr/bin/rocm-smi --export-path ~/.local/bin
distrobox-export --bin /usr/bin/clinfo --export-path ~/.local/bin

# Media
distrobox-export --bin /usr/bin/ffmpeg --export-path ~/.local/bin
distrobox-export --bin /usr/bin/ffprobe --export-path ~/.local/bin

# Dev tools
distrobox-export --bin /usr/bin/gcc --export-path ~/.local/bin
distrobox-export --bin /usr/bin/g++ --export-path ~/.local/bin
distrobox-export --bin /usr/bin/cmake --export-path ~/.local/bin
distrobox-export --bin /usr/bin/ninja --export-path ~/.local/bin
distrobox-export --bin /usr/bin/make --export-path ~/.local/bin

# OBS as GUI app (shows in COSMIC launcher)
# distrobox-export --app obs-studio

echo "All exports done. Tools available in ~/.local/bin/"
