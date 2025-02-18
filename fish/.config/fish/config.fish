if status is-interactive
    # Commands to run in interactive sessions can go here
end

export PATH="$PATH:$HOME/go/bin"
export GOPRIVATE="github.com/sumup/*"
/opt/homebrew/bin/brew shellenv | source
# gh copilot alias -- fish | source
starship init fish | source
zoxide init fish | source
fzf --fish | source
