# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

alias gd="cd $HOME/git"
alias ss-osl="sshuttle --remote beddari@osl-login-1.iaas.uio.no 129.240.0.0/16"
alias ss-bgo="sshuttle --remote beddari@bgo-login-1.iaas.uib.no 129.177.0.0/16 172.16.24.0/21 172.16.32.0/21 192.168.10.0/24"
alias ss-trd="sshuttle --remote beddari@trd-login-1.iaas.ntnu.no 129.241.0.0/16 10.171.86.0/24 10.171.91.0/24"

alias ss-dev01="sshuttle --remote beddari@pilot.iaas.uib.no 129.177.0.0/16 192.168.10.0/24"
alias ss-dev02="sshuttle --remote beddari@129.241.14.144 129.241.0.0/16 10.171.92.0/24 10.171.93.0/24"

export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=10000

# Boxen, git stuff
[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh

boxen_gitcompletion=/opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash
boxen_gitprompt=/opt/boxen/homebrew/etc/bash_completion.d/git-prompt.sh
[ -f $boxen_gitcompletion ] && source $boxen_gitcompletion
[ -f $boxen_gitprompt ] && source $boxen_gitprompt

linux_gitprompt=/usr/share/doc/git/contrib/completion/git-prompt.sh
[ -f $linux_gitprompt ] && source $linux_gitprompt

# chruby
chruby=/usr/local/share/chruby
if [ -f $chruby/chruby.sh ]; then
  source $chruby/chruby.sh
  source $chruby/auto.sh
fi

if [ -f "$HOME/bin/virtualenvwrapper.sh" ]; then
  source "$HOME/bin/virtualenvwrapper.sh"
fi

# prompt
export GIT_PS1_SHOWUNTRACKEDFILES=1
export PS1='\u@\h:\w$(__git_ps1)\$ '

# vagrant
export VAGRANT_DEFAULT_PROVIDER=libvirt
