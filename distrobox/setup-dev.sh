#!/bin/bash
set -euo pipefail

# ROCm repository (v7.2 for Ubuntu Noble)
wget https://repo.radeon.com/amdgpu-install/7.2/ubuntu/noble/amdgpu-install_7.2.70200-1_all.deb
sudo apt install -y ./amdgpu-install_7.2.70200-1_all.deb
rm amdgpu-install_7.2.70200-1_all.deb
sudo apt update

# Skip linux-headers and amdgpu-dkms — distrobox uses host kernel, no DKMS needed

# ROCm userspace only
sudo apt install -y python3-setuptools python3-wheel
# Group membership not needed in distrobox — GPU access via --device passthrough
sudo groupadd -f render
sudo groupadd -f video
sudo usermod -a -G render,video $LOGNAME
sudo apt install -y rocm

# Media tools
sudo apt install -y ffmpeg v4l-utils clinfo
