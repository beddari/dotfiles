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

git_osx=/usr/local/etc/bash_completion.d
if [[ -d $git_osx ]]; then
  source /usr/local/etc/bash_completion.d/git-completion.bash
  source /usr/local/etc/bash_completion.d/git-prompt.sh
fi

linux_gitprompt=/usr/share/doc/git-core-doc/contrib/completion/git-prompt.sh
[[ -f $linux_gitprompt ]] && source $linux_gitprompt

# chruby
chruby=/usr/local/share/chruby
if [[ -f $chruby/chruby.sh ]]; then
  source $chruby/chruby.sh
  source $chruby/auto.sh
fi

if [[ -f "$HOME/bin/virtualenvwrapper.sh" ]]; then
  source "$HOME/bin/virtualenvwrapper.sh"
fi

# prompt
export GIT_PS1_SHOWUNTRACKEDFILES=1
export PS1='\u@\h:\w$(__git_ps1)\$ '

# keychain
eval $(keychain --eval -q)
