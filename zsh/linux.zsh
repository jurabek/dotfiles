export EDITOR=zeditor
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export HSA_OVERRIDE_GFX_VERSION=11.0.0
export OBS_WEBSOCKET_URL=obsws://localhost:4456/PZORf1nw0StQEbQQ

export DOCKER_HOST=unix://$(podman info --format '{{.Host.RemoteSocket.Path}}')

RESOLVE_SCRIPT_API="/opt/resolve/Developer/Scripting"
RESOLVE_SCRIPT_LIB="/opt/resolve/libs/Fusion/fusionscript.so"
PYTHONPATH="$PYTHONPATH:$RESOLVE_SCRIPT_API/Modules/"

# Bitwarden SSH Agent
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

alias docker=podman
alias zed=zeditor

# opencode
export PATH=/home/jurabek/.opencode/bin:$PATH
