# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# source /usr/share/nvm/init-nvm.sh

# secrets
if [ -f $HOME/.encrypt ]; then
    source $HOME/.encrypt
fi

# env vars
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:$HOME/.local/go/bin:$HOME/.local/bin"
export EDITOR=zeditor
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export PATH="$PATH:$(go env GOPATH)/bin"
export NVM_DIR="$HOME/.nvm"

# export ANDROID_HOME=$HOME/Android/Sdk
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/platform-tools
export HSA_OVERRIDE_GFX_VERSION=11.0.0
export OBS_WEBSOCKET_URL=obsws://localhost:4456/PZORf1nw0StQEbQQ

export DOCKER_HOST=unix://$(podman info --format '{{.Host.RemoteSocket.Path}}')

RESOLVE_SCRIPT_API="/opt/resolve/Developer/Scripting"
RESOLVE_SCRIPT_LIB="/opt/resolve/libs/Fusion/fusionscript.so"
PYTHONPATH="$PYTHONPATH:$RESOLVE_SCRIPT_API/Modules/"

# Bitwarden SSH Agent
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

glm() {
    export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
    export ANTHROPIC_AUTH_TOKEN="${Z_AI_API_KEY}"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7"
    claude "$@"
}


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gh fzf nvm golang docker kubectl tmux archlinux pip tmux zsh-autocomplete zsh-syntax-highlighting zsh-you-should-use)

source $ZSH/oh-my-zsh.sh
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh

alias zed=zeditor
alias cls=clear
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
# opencode
# export PATH=/home/jurabek/.opencode/bin:$PATH


alias docker=podman

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# opencode
export PATH=/home/jurabek/.opencode/bin:$PATH
