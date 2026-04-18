#!/bin/bash

set -e

APP_ID="dev.zed.Zed"

echo "Applying Flatpak overrides for $APP_ID..."

flatpak override --user \
  --filesystem=/var/home/"$USER"/.local/go:ro \
  --env=PATH="$PATH":/app/bin:/run/host/usr/bin \
  "$APP_ID"

echo "Done! Overrides applied:"
flatpak override --user --show "$APP_ID"

echo ""
echo "Restarting Zed..."
pkill -f zed 2>/dev/null || true
sleep 1
flatpak run "$APP_ID" &
