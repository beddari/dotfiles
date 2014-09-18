alias gd="cd $HOME/git"

export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Boxen, git stuff
[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh
if [ -f /opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash ]; then
   source /opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash
fi
if [ -f /opt/boxen/homebrew/etc/bash_completion.d/git-prompt.sh ]; then
   source /opt/boxen/homebrew/etc/bash_completion.d/git-prompt.sh
fi
if [ -f /usr/share/doc/git/contrib/completion/git-prompt.sh ]; then
   source /usr/share/doc/git/contrib/completion/git-prompt.sh
fi 

# chruby
if [ -f /usr/local/share/chruby/chruby.sh ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi

export GIT_PS1_SHOWUNTRACKEDFILES=1
export PS1='\u@\H:\w$(__git_ps1)\$ '
