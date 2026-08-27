# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# source /usr/share/nvm/init-nvm.sh

# secrets
if [ -f $HOME/.encrypt ]; then
    source $HOME/.encrypt
fi

export GOPRIVATE="github.com/sumup/*"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_HOME=$HOME/Library/Android/sdk

# env vars
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:$HOME/.local/go/bin:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export NVM_DIR="$HOME/.nvm"

# export ANDROID_HOME=$HOME/Android/Sdk
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/platform-tools

export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="${Z_AI_API_KEY}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"

export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="${Z_AI_API_KEY}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gh fzf golang docker kubectl tmux zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use)

source $ZSH/oh-my-zsh.sh
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='zed'
fi

# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"

alias cls=clear
alias cd=z
alias ls=lsd
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# OS-specific configs
if [[ "$(uname)" == "Darwin" ]]; then
    [ -f ${ZSH_CUSTOM}/macos.zsh ] && source ${ZSH_CUSTOM}/macos.zsh
elif [[ "$(uname)" == "Linux" ]]; then
    [ -f ${ZSH_CUSTOM}/linux.zsh ] && source ${ZSH_CUSTOM}/linux.zsh
fi

# opencode
export PATH=/Users/jurabekazizkhujaev/.opencode/bin:$PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/jurabekazizkhujaev/.local/bin:$PATH"
