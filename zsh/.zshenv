# env vars - sourced by ALL shells (including Zed, editors, etc.)

# secrets
if [ -f $HOME/.encrypt ]; then
    source $HOME/.encrypt
fi

# Oh My Zsh location
export ZSH="$HOME/.oh-my-zsh"

# PATH - add your binaries (hardcoded GOPATH to avoid circular dependency)
export PATH="$PATH:$HOME/.local/go/bin:$HOME/.local/bin:$HOME/.cargo/bin:/home/jurabek/go/bin:/home/jurabek/.opencode/bin"

# Editor
export EDITOR=zeditor
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# Node version manager
export NVM_DIR="$HOME/.nvm"

# GPU / Resolve
export HSA_OVERRIDE_GFX_VERSION=11.0.0
export OBS_WEBSOCKET_URL="obsws://localhost:4456/PZORf1nw0StQEbQQ"

# Docker/Podman
export DOCKER_HOST="unix://$(podman info --format '{{.Host.RemoteSocket.Path}}')"

# Bitwarden SSH Agent
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
