# Source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# gpg
if [[ $(command -v gpg2) ]]; then
  alias gpg="gpg2"
fi

alias gd="cd $HOME/git"
eval "$(hub alias -s)"

export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=10000

export GOPATH=$HOME/src/golang

export VISUAL=vim
export EDITOR="$VISUAL"

git_osx=/usr/local/etc/bash_completion.d
if [[ -d $git_osx ]]; then
  source /usr/local/etc/bash_completion.d/git-completion.bash
  source /usr/local/etc/bash_completion.d/git-prompt.sh
fi

linux_gitprompt=/usr/share/doc/git-core-doc/contrib/completion/git-prompt.sh
[[ -f $linux_gitprompt ]] && source $linux_gitprompt

# source chruby if it is present
chruby=/usr/local/share/chruby
[[ -f $chruby/chruby.sh ]] && { source $chruby/chruby.sh; source $chruby/auto.sh; }

# source local virtualenvwrapper, if present
[[ -f "$HOME/bin/virtualenvwrapper.sh" ]] && source "$HOME/bin/virtualenvwrapper.sh"

# use hashicorp packer binary
[[ -f "$HOME/bin/packer" ]] && alias packer="~/bin/packer"

# prompt
export GIT_PS1_SHOWUNTRACKEDFILES=1
export PS1='\u@\h:\w$(__git_ps1)\$ '

# keychain
if [[ $(command -v keychain) ]]; then
  eval $(keychain --eval -q)
fi
