# DisplayLink evdi Setup for Fedora Atomic Desktop

Complete setup for DisplayLink support on Fedora Atomic Desktop (Silverblue/Kinoite) using ostree.

## Quick Start

```bash
cd ~/dev/dotfiles/fedora/evdi
./setup.sh
```

## What This Does

1. Installs `dkms` via `rpm-ostree` (requires reboot)
2. Installs DisplayLink RPM from [displaylink-rpm](https://github.com/displaylink-rpm/displaylink-rpm)
3. Configures systemd override to load evdi module on ostree
4. Handles SELinux contexts for kernel module loading

## Files

| File | Purpose |
|------|---------|
| `setup.sh` | Main installation script - run this first |
| `install-dkms.sh` | Install DKMS via rpm-ostree |
| `install-displaylink.sh` | Install DisplayLink RPM |
| `configure-override.sh` | Configure systemd override |
| `post-kernel-update.sh` | Rebuild module after kernel updates |
| `check.sh` | Quick status check script |

## Manual Installation Steps

### Step 1: Install DKMS

DKMS needs to be installed via rpm-ostree (layered package):

```bash
./install-dkms.sh
```

**This requires a reboot** to complete the installation.

### Step 2: Install DisplayLink RPM

After reboot, install the DisplayLink driver:

```bash
./install-displaylink.sh
```

This downloads and installs the latest DisplayLink RPM from the official repository.

### Step 3: Configure Systemd Override

Configure the systemd service override for ostree:

```bash
./configure-override.sh
```

### Step 4: Verify

```bash
./check.sh
```

## After Kernel Updates

Each time you get a kernel update, rebuild the module:

```bash
./post-kernel-update.sh
```

## How It Works

### The Problem

On Fedora Atomic Desktop with ostree:
- `/lib/modules` is read-only (immutable ostree filesystem)
- DKMS builds modules but can't install them to standard locations
- `modprobe evdi` fails because the module isn't found

### The Solution

1. DKMS builds the module to `/var/lib/dkms/evdi/`
2. Systemd service override decompresses module to `/var/lib/evdi/`
3. Sets correct SELinux context (`modules_object_t`)
4. Loads module with `insmod` using full path (bypasses need for `/lib/modules`)

### SELinux Contexts

The script fixes two SELinux issues:
- Executable script: `bin_t` context (allows systemd to run it)
- Kernel module: `modules_object_t` context (allows insmod to load it)

## Troubleshooting

### Module not loaded

```bash
# Check service logs
journalctl -xeu displaylink-driver.service

# Check status
./check.sh
```

### DKMS module not built

```bash
# Check DKMS status
dkms status

# Rebuild manually
sudo dkms install evdi/1.14.12 -k $(uname -r)
```

### Device not detected

```bash
# Check if device is visible
lsusb | grep -i display

# Check udev rules
cat /etc/udev/rules.d/99-displaylink.rules
```

### SELinux issues

```bash
# Check if SELinux is enforcing
getenforce

# Check AVC denials
sudo ausearch -m avc -ts recent | grep evdi
```

## References

- [displaylink-rpm GitHub](https://github.com/displaylink-rpm/displaylink-rpm)
- [DisplayLink Releases](https://github.com/displaylink-rpm/displaylink-rpm/releases)
- [Fedora Atomic Documentation](https://docs.fedoraproject.org/en-US/fedora-silverblue/)
- [OSTree Documentation](https://ostreedev.github.io/ostree/)
