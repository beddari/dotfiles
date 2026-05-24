# Homebrew
if [[ "$(uname)" == "Darwin" ]]; then
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"

export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Environment
if [[ "$(uname)" == "Darwin" ]]; then
    # secure enclave fingerprint based ssh
    # https://gist.github.com/arianvp/5f59f1783e3eaf1a2d4cd8e952bb4acf
    export SSH_SK_PROVIDER=/usr/lib/ssh-keychain.dylib
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    # Remap non-breaking space (Option+Space on Norwegian keyboard) to regular space
    bindkey -s '\xc2\xa0' ' '
    # Set config folder for e.g sops
    export XDG_CONFIG_HOME="$HOME/.config"
fi
export EDITOR=vim
export LESS='-FRXx4'

# History
HISTFILE=~/.histfile
HISTSIZE=200000
SAVEHIST=200000
HISTORY_RETENTION_DAYS=21
HISTORY_PRUNE_INTERVAL_SECONDS=86400

# Keep rich, shared history and ensure Ctrl-R works across keymaps.
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
bindkey '^R' history-incremental-search-backward
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' kill-whole-line
bindkey -M viins '^W' backward-kill-word

# Keep only recent timestamped history entries in HISTFILE.
_prune_history_file() {
    [[ -s "$HISTFILE" ]] || return 0

    local prune_state_file="${HISTFILE}.prune-state"
    local lock_file="${HISTFILE}.prune-lock"
    local last_prune=0
    local cutoff
    local tmp_file="${HISTFILE}.tmp.$$"

    if [[ -r "$prune_state_file" ]]; then
        read -r last_prune < "$prune_state_file"
        [[ "$last_prune" == <-> ]] || last_prune=0
    fi

    (( EPOCHSECONDS - last_prune >= HISTORY_PRUNE_INTERVAL_SECONDS )) || return 0

    # Non-blocking lock: skip prune if another shell is already pruning.
    if ! ( set -o noclobber; : > "$lock_file" ) 2>/dev/null; then
        return 0
    fi

    cutoff=$(( EPOCHSECONDS - HISTORY_RETENTION_DAYS * 86400 ))

    if awk -v cutoff="$cutoff" '
        /^: [0-9]+:[0-9]+;/ {
            if (match($0, /^: ([0-9]+):[0-9]+;/, m) && m[1] >= cutoff) {
                print
            }
            next
        }
        { print }
    ' "$HISTFILE" > "$tmp_file"; then
        mv "$tmp_file" "$HISTFILE"
        print -r -- "$EPOCHSECONDS" > "$prune_state_file"
    else
        rm -f "$tmp_file"
    fi

    rm -f "$lock_file"
}
_prune_history_file

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

# Brew wrapper: auto-sync vscode/go extensions from Brewfile after upgrade
brew() {
    command brew "$@"
    if [[ "$1" == "upgrade" ]]; then
        command brew bundle upgrade --global
    fi
}

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

# Install local TERM terminfo on a remote host
function terminfo-install() {
    infocmp "$TERM" | ssh "$@" -- tic -x -
}
compdef terminfo-install=ssh
