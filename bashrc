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
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Prompt
eval "$(starship init bash)"

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

# Brew wrapper: auto-sync vscode/go extensions from Brewfile after upgrade
brew() {
    command brew "$@"
    if [[ "$1" == "upgrade" ]]; then
        local bf="$HOME/kode/dotfiles/Brewfile.$(uname)"
        [[ -f "$bf" ]] && command brew bundle --file="$bf" --vscode --go
    fi
}

# Completions
if type brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"
    if [[ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
        . "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
    fi
fi

# zmx
if command -v zmx &>/dev/null; then
    eval "$(zmx completions bash)"
fi
