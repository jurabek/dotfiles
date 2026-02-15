#!/bin/bash
# Quick status check for DisplayLink evdi setup on Fedora Atomic Desktop

echo "==> DisplayLink evdi Status Check"
echo "=================================="
echo ""

# System info
echo "System: $(hostnamectl | grep "Operating System" | awk -F: '{print $2}' | xargs)"
echo "Kernel: $(uname -r)"
echo ""

# Check if DKMS is installed
echo "==> DKMS:"
if rpm -q dkms &>/dev/null; then
    echo "✓ DKMS is installed: $(rpm -q dkms)"
else
    echo "✗ DKMS is NOT installed"
    echo "  Run: ./install-dkms.sh"
fi
echo ""

# Check if DisplayLink is installed
echo "==> DisplayLink RPM:"
if rpm -q displaylink &>/dev/null; then
    echo "✓ DisplayLink is installed: $(rpm -q displaylink)"
else
    echo "✗ DisplayLink is NOT installed"
    echo "  Run: ./install-displaylink.sh"
fi
echo ""

# Check if module is loaded
echo "==> evdi module status:"
if lsmod | grep -q "^evdi "; then
    echo "✓ evdi module is LOADED"
    lsmod | grep "^evdi "
else
    echo "✗ evdi module is NOT loaded"
fi
echo ""

# Check DKMS status
echo "==> DKMS module status:"
DKMS_STATUS=$(dkms status | grep evdi)
if [ -n "$DKMS_STATUS" ]; then
    echo "$DKMS_STATUS"
else
    echo "No DKMS evdi modules found"
    echo "  Run: sudo dkms install evdi/1.14.12 -k \$(uname -r)"
fi
echo ""

# Check module source exists
KERNEL_VERSION=$(uname -r)
MODULE_SRC="/var/lib/dkms/evdi/1.14.12/${KERNEL_VERSION}/x86_64/module/evdi.ko.xz"
if [ -f "$MODULE_SRC" ]; then
    echo "✓ Module source exists:"
    echo "  $MODULE_SRC"
    ls -lh "$MODULE_SRC" | awk '{print "  Size: " $5}'
else
    echo "✗ Module source NOT found:"
    echo "  $MODULE_SRC"
    echo "  Run: sudo dkms install evdi/1.14.12 -k ${KERNEL_VERSION}"
fi
echo ""

# Check decompressed module
echo "==> Decompressed module:"
if [ -f "/var/lib/evdi/evdi.ko" ]; then
    echo "✓ Decompressed module exists: /var/lib/evdi/evdi.ko"
    ls -lh /var/lib/evdi/evdi.ko | awk '{print "  Size: " $5}'
    ls -laZ /var/lib/evdi/evdi.ko | awk '{print "  Context: " $4 " " $5}'
else
    echo "✗ Decompressed module NOT found: /var/lib/evdi/evdi.ko"
fi
echo ""

# Check systemd override
echo "==> Systemd override:"
OVERRIDE_FILE="/etc/systemd/system/displaylink-driver.service.d/override.conf"
if [ -f "$OVERRIDE_FILE" ]; then
    echo "✓ Override exists: $OVERRIDE_FILE"
else
    echo "✗ Override NOT found: $OVERRIDE_FILE"
    echo "  Run: ./configure-override.sh"
fi
echo ""

# Check service status
echo "==> DisplayLink service status:"
if systemctl list-unit-files | grep -q displaylink-driver.service; then
    if systemctl is-active --quiet displaylink-driver.service; then
        echo "✓ displaylink-driver.service is ACTIVE"
    else
        echo "✗ displaylink-driver.service is NOT active"
    fi
    systemctl status displaylink-driver.service --no-pager -l | head -8
else
    echo "✗ displaylink-driver.service NOT found"
    echo "  (This is expected if DisplayLink RPM is not installed)"
fi
echo ""

# Check for DisplayLink device
echo "==> USB DisplayLink devices:"
DISPLAYLINK_DEVICES=$(lsusb | grep -i display)
if [ -n "$DISPLAYLINK_DEVICES" ]; then
    echo "$DISPLAYLINK_DEVICES"
else
    echo "No DisplayLink devices detected"
    echo "  Connect your DisplayLink device and check with: lsusb | grep -i display"
fi
echo ""

# Check for errors in service logs
echo "==> Recent service errors:"
ERRORS=$(journalctl -xeu displaylink-driver.service --no-pager -n 10 2>/dev/null | grep -i error)
if [ -n "$ERRORS" ]; then
    echo "$ERRORS"
else
    echo "No recent errors found"
fi
