#!/bin/bash
# Install DKMS via rpm-ostree on Fedora Atomic Desktop
# DKMS is required for building the evdi kernel module

set -e

echo "==> Installing DKMS via rpm-ostree..."

# Check if already installed
if rpm -q dkms &>/dev/null; then
    echo "DKMS is already installed:"
    rpm -q dkms
    exit 0
fi

# Install DKMS
sudo rpm-ostree install dkms

echo ""
echo "==> DKMS installed successfully!"
echo ""
echo "==> IMPORTANT: You must reboot for the changes to take effect."
echo "After reboot, continue with the DisplayLink installation."
echo ""
echo "Run: systemctl reboot"
