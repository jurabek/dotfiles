#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_file() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "backup: $dest -> $dest.bak"
        mv "$dest" "$dest.bak"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "linked: $dest -> $src"
}

# files
link_file "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/electron/electron-flags.conf" "$HOME/.config/electron-flags.conf"
link_file "$DOTFILES/git/config" "$HOME/.config/git/config"
link_file "$DOTFILES/tmux/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
link_file "$DOTFILES/hypr/bindings.conf" "$HOME/.config/hypr/bindings.conf"
link_file "$DOTFILES/hypr/envs.conf" "$HOME/.config/hypr/envs.conf"

# directories
link_file "$DOTFILES/pipewire" "$HOME/.config/pipewire"
link_file "$DOTFILES/waybar" "$HOME/.config/waybar"

# opendeck profiles (copy to all device folders, symlinks not supported)
for device_dir in "$HOME/.config/opendeck/profiles/"*/; do
    [ -d "$device_dir" ] || continue
    for profile in "$DOTFILES/opendeck/profiles/"*.json; do
        [ -f "$profile" ] || continue
        dest="$device_dir$(basename "$profile")"
        cp "$profile" "$dest"
        echo "copied: $profile -> $dest"
    done
done

echo "done"
