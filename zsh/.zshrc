# secrets
if [ -f "$HOME/.encrypt" ]; then
    source "$HOME/.encrypt"
fi

export GOPRIVATE="github.com/sumup/*"

# env vars
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:$HOME/.local/go/bin:$HOME/.local/bin:$HOME/go/bin"

# Skip OMZ update checks and completion dir audits (compaudit) on every start.
zstyle ':omz:update' mode disabled
ZSH_DISABLE_COMPFIX=true

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git gh golang docker kubectl tmux zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use)

source "$ZSH/oh-my-zsh.sh"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='zed'
fi

export ARCHFLAGS="-arch $(uname -m)"

alias cls=clear
alias cd=z
alias ls=lsd
alias uuidgen="$HOME/go/bin/uuidgen"

# Cache generated init scripts so we do not fork starship/zoxide/fzf on every shell.
_zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_zsh_cache"

_zsh_regen_init() {
  local cmd=$1 out=$2
  shift 2
  (( $+commands[$cmd] )) || return
  if [[ ! -s $out || ${commands[$cmd]:A} -nt $out ]]; then
    command "$cmd" "$@" >| "$out"
  fi
  source "$out"
}

_zsh_regen_init starship "$_zsh_cache/starship.zsh" init zsh
_zsh_regen_init zoxide "$_zsh_cache/zoxide.zsh" init zsh
_zsh_regen_init fzf "$_zsh_cache/fzf.zsh" --zsh
unset _zsh_cache

# OS-specific configs
if [[ "$OSTYPE" == darwin* ]]; then
    [[ -f ${ZSH_CUSTOM}/macos.zsh ]] && source ${ZSH_CUSTOM}/macos.zsh
elif [[ "$OSTYPE" == linux* ]]; then
    [[ -f ${ZSH_CUSTOM}/linux.zsh ]] && source ${ZSH_CUSTOM}/linux.zsh
fi

export PATH="$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.local/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
