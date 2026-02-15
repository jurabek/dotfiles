#!/bin/bash
# Configure systemd override for DisplayLink on Fedora Atomic Desktop
# This creates the necessary override to load the evdi module on ostree

set -e

EVDI_VERSION="1.14.12"
OVERRIDE_FILE="/etc/systemd/system/displaylink-driver.service.d/override.conf"
EVDI_DIR="/var/lib/evdi"

echo "==> Configuring DisplayLink systemd override for Fedora Atomic Desktop..."
echo ""

# Step 1: Create evdi directory
echo "==> Creating $EVDI_DIR..."
sudo mkdir -p "$EVDI_DIR"

# Step 2: Build DKMS module for current kernel
echo "==> Building DKMS module for kernel $(uname -r)..."
if sudo dkms install "evdi/$EVDI_VERSION" -k "$(uname -r)" 2>/dev/null; then
    echo "✓ DKMS module built successfully"
else
    echo "⚠ DKMS install returned non-zero, checking if module exists..."
fi

# Step 3: Verify module source exists
MODULE_SRC="/var/lib/dkms/evdi/${EVDI_VERSION}/$(uname -r)/x86_64/module/evdi.ko.xz"
if [ ! -f "$MODULE_SRC" ]; then
    echo "⚠ WARNING: Module not found at $MODULE_SRC"
    echo "  This is expected if you just installed DisplayLink and haven't rebooted yet."
    echo "  After reboot, run: sudo dkms install evdi/${EVDI_VERSION} -k \$(uname -r)"
else
    echo "✓ Module source found: $MODULE_SRC"
fi

# Step 4: Create systemd override
echo "==> Creating systemd override at $OVERRIDE_FILE..."
sudo tee "$OVERRIDE_FILE" > /dev/null << 'OVERRIDEEOF'
[Service]
ExecStartPre=
ExecStartPre=/bin/bash -c 'mkdir -p /var/lib/evdi && xz -dk -c /var/lib/dkms/evdi/1.14.12/$(uname -r)/x86_64/module/evdi.ko.xz > /var/lib/evdi/evdi.ko && chcon -t modules_object_t /var/lib/evdi/evdi.ko && insmod /var/lib/evdi/evdi.ko initial_device_count=4 || true'
OVERRIDEEOF

echo "✓ Systemd override created"

# Step 5: Set up persistent SELinux contexts
echo "==> Setting up persistent SELinux contexts..."
if command -v semanage &>/dev/null; then
    # Add file context for the module
    sudo semanage fcontext -a -t modules_object_t "/var/lib/evdi/evdi.ko" 2>/dev/null || true
    echo "✓ SELinux context configured"
else
    echo "⚠ semanage not found, skipping persistent context configuration"
    echo "  Install policycoreutils-python-utils if needed"
fi

# Step 6: Reload systemd
echo "==> Reloading systemd..."
sudo systemctl daemon-reload

# Step 7: Check if service exists and is running
if systemctl list-unit-files | grep -q displaylink-driver.service; then
    echo "==> Restarting displaylink-driver.service..."
    sudo systemctl restart displaylink-driver.service

    # Wait for service to start
    sleep 3

    # Check status
    if systemctl is-active --quiet displaylink-driver.service; then
        echo "✓ Service is active"
    else
        echo "⚠ Service is not active. Check logs:"
        echo "  journalctl -xeu displaylink-driver.service"
    fi
else
    echo "⚠ displaylink-driver.service not found"
    echo "  This is expected if you just installed DisplayLink and haven't rebooted yet."
fi

echo ""
echo "==> Configuration complete!"
echo ""
echo "If this is a fresh installation, reboot to finalize:"
echo "  systemctl reboot"
