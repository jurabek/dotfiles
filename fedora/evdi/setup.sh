#!/bin/bash
# Complete DisplayLink setup for Fedora Atomic Desktop
# This script installs DKMS, DisplayLink RPM, and configures the systemd override

set -e

DISPLAYLINK_VERSION="v6.1.1-5"
DISPLAYLINK_RPM="displaylink-1.14.12-1.github_evdi.x86_64.rpm"
DISPLAYLINK_URL="https://github.com/displaylink-rpm/displaylink-rpm/releases/download/${DISPLAYLINK_VERSION}/${DISPLAYLINK_RPM}"

echo "==> DisplayLink Setup for Fedora Atomic Desktop"
echo "==============================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run this script as root. Use sudo only when needed."
    exit 1
fi

# Step 1: Check if DKMS is installed
echo "==> Step 1: Checking DKMS installation..."
if ! rpm -q dkms &>/dev/null; then
    echo "DKMS is not installed. Installing via rpm-ostree..."
    echo ""
    echo "Running: sudo rpm-ostree install dkms"
    sudo rpm-ostree install dkms

    echo ""
    echo "==> IMPORTANT: You must reboot to complete the DKMS installation!"
    echo "After reboot, run this script again to continue with DisplayLink installation."
    echo ""
    echo "Run: systemctl reboot"
    exit 0
else
    echo "✓ DKMS is already installed"
fi
echo ""

# Step 2: Check if DisplayLink RPM is installed
echo "==> Step 2: Checking DisplayLink installation..."
if rpm -q displaylink &>/dev/null; then
    echo "✓ DisplayLink RPM is already installed"
else
    echo "DisplayLink RPM not found. Installing..."
    echo "Downloading from: $DISPLAYLINK_URL"

    # Download to temporary location
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT

    curl -L -o "$TMP_DIR/$DISPLAYLINK_RPM" "$DISPLAYLINK_URL"

    echo "Installing DisplayLink RPM..."
    sudo rpm-ostree install "$TMP_DIR/$DISPLAYLINK_RPM"

    echo ""
    echo "==> IMPORTANT: You must reboot to complete the DisplayLink installation!"
    echo "After reboot, run this script again to configure the systemd override."
    echo ""
    echo "Run: systemctl reboot"
    exit 0
fi
echo ""

# Step 3: Configure systemd override
echo "==> Step 3: Configuring systemd override..."
./configure-override.sh
echo ""

# Step 4: Verify setup
echo "==> Step 4: Verifying setup..."
sleep 2
./check.sh

echo ""
echo "==> Setup complete!"
echo "==> Your DisplayLink device should now be working."
