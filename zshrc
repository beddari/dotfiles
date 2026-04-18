# Homebrew
if [[ "$(uname)" == "Darwin" ]]; then
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    export SSH_SK_PROVIDER=/usr/lib/ssh-keychain.dylib
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    # Remap non-breaking space (Option+Space on Norwegian keyboard) to regular space
    bindkey -s '\xc2\xa0' ' '
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"

# Environment
export EDITOR=vim
export LESS='-FRXx4'

# History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Cursor shape: blinking bar
echo -ne '\e[5 q'

# Prompt
eval "$(starship init zsh)"

# Window title
function _set_window_title() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        print -Pn "\e]0;ssh → ${USER}@${HOST%%.*}: ${PWD/#$HOME/~}\a"
    else
        print -Pn "\e]0;${PWD/#$HOME/~}\a"
    fi
}
precmd_functions+=(_set_window_title)

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
if command -v brew &>/dev/null; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit
compinit

# zmx
if command -v zmx &>/dev/null; then
    eval "$(zmx completions zsh)"
fi
