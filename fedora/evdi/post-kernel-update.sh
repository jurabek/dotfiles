#!/bin/bash
# Rebuild evdi module after kernel update on Fedora Atomic Desktop
# Run this after each kernel update to rebuild and load the evdi module

set -e

EVDI_VERSION="1.14.12"

echo "==> Rebuilding evdi module for new kernel $(uname -r)..."
echo ""

# Step 1: Remove old module from all kernels
echo "==> Removing old DKMS modules..."
sudo dkms remove "evdi/$EVDI_VERSION" --all 2>/dev/null || true

# Step 2: Install for current kernel
echo "==> Building DKMS module for kernel $(uname -r)..."
sudo dkms install "evdi/$EVDI_VERSION" -k "$(uname -r)"

# Step 3: Verify module was built
MODULE_SRC="/var/lib/dkms/evdi/${EVDI_VERSION}/$(uname -r)/x86_64/module/evdi.ko.xz"
if [ -f "$MODULE_SRC" ]; then
    echo "✓ Module built successfully: $MODULE_SRC"
else
    echo "✗ ERROR: Module build failed"
    echo "  Check DKMS logs: sudo dkms status"
    exit 1
fi

# Step 4: Remove old module file to force refresh
echo "==> Removing old module file..."
sudo rm -f /var/lib/evdi/evdi.ko

# Step 5: Restart the service (it will recreate and load the module)
echo "==> Restarting displaylink service..."
sudo systemctl restart displaylink-driver.service

# Step 6: Wait and verify
sleep 3
echo ""
if lsmod | grep -q "^evdi "; then
    echo "✓ SUCCESS: evdi module loaded for kernel $(uname -r)"
    lsmod | grep "^evdi "
else
    echo "✗ ERROR: Module failed to load. Check logs:"
    echo "  journalctl -xeu displaylink-driver.service"
    exit 1
fi

echo ""
echo "==> Kernel update complete!"
