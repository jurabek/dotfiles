#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

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

link_file "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

case "$(uname)" in
    Darwin)
        link_file "$SCRIPT_DIR/macos.zsh" "$ZSH_CUSTOM/macos.zsh"
        ;;
    Linux)
        link_file "$SCRIPT_DIR/linux.zsh" "$ZSH_CUSTOM/linux.zsh"
        ;;
esac

echo "done"
