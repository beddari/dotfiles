# Homebrew
if [[ "$(uname)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export SSH_SK_PROVIDER=/usr/lib/ssh-keychain.dylib
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"

# Environment
export EDITOR=vim
export LESS='-FRXx4'
export NODE_OPTIONS="--no-deprecation"

# History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Prompt
eval "$(starship init zsh)"

# Dircolors
if [[ -f ~/.dircolors ]]; then
    if command -v gdircolors &>/dev/null; then
        eval "$(gdircolors ~/.dircolors)"
        alias ls='gls --color=auto'
    elif command -v dircolors &>/dev/null; then
        eval "$(dircolors ~/.dircolors)"
        alias ls='ls --color=auto'
    fi
fi

# Completions
if type brew &>/dev/null; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit
compinit

# zmx
if command -v zmx &>/dev/null; then
    eval "$(zmx completions zsh)"
fi
