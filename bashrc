alias gd="cd $HOME/git"

export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Boxen, git stuff
[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh

boxen_gitcompletion=/opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash
boxen_gitprompt=/opt/boxen/homebrew/etc/bash_completion.d/git-prompt.bash
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

# python virtualenvs
if [ ! -d "$HOME/virtualenvs" ]; then
  mkdir -p "$HOME/virtualenvs"
fi
export WORKON_HOME=$HOME/virtualenvs
if [ -f "$HOME/bin/virtualenvwrapper.sh" ]; then
  source "$HOME/bin/virtualenvwrapper.sh"
fi

# prompt
export GIT_PS1_SHOWUNTRACKEDFILES=1
export PS1='\u@\H:\w$(__git_ps1)\$ '
