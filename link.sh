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

# directories
link_file "$DOTFILES/pipewire" "$HOME/.config/pipewire"
link_file "$DOTFILES/waybar" "$HOME/.config/waybar"

echo "done"
