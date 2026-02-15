#!/bin/bash
# Install DisplayLink RPM on Fedora Atomic Desktop
# Downloads and installs the latest DisplayLink driver from the official repository

set -e

DISPLAYLINK_VERSION="v6.1.1-5"
DISPLAYLINK_RPM="displaylink-1.14.12-1.github_evdi.x86_64.rpm"
DISPLAYLINK_URL="https://github.com/displaylink-rpm/displaylink-rpm/releases/download/${DISPLAYLINK_VERSION}/${DISPLAYLINK_RPM}"

echo "==> Installing DisplayLink RPM..."
echo "Version: $DISPLAYLINK_VERSION"
echo "Source: $DISPLAYLINK_URL"
echo ""

# Check if already installed
if rpm -q displaylink &>/dev/null; then
    echo "DisplayLink is already installed:"
    rpm -q displaylink
    echo ""
    echo "To reinstall, first remove with: sudo rpm-ostree override remove displaylink"
    exit 0
fi

# Create temporary directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Download RPM
echo "Downloading $DISPLAYLINK_RPM..."
curl -L -o "$TMP_DIR/$DISPLAYLINK_RPM" "$DISPLAYLINK_URL"

# Verify download
if [ ! -f "$TMP_DIR/$DISPLAYLINK_RPM" ]; then
    echo "ERROR: Failed to download DisplayLink RPM"
    exit 1
fi

# Install via rpm-ostree
echo "Installing via rpm-ostree..."
sudo rpm-ostree install "$TMP_DIR/$DISPLAYLINK_RPM"

echo ""
echo "==> DisplayLink RPM installed successfully!"
echo ""
echo "==> IMPORTANT: You must reboot for the changes to take effect."
echo ""
echo "Run: systemctl reboot"
