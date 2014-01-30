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

export GIT_PS1_SHOWUNTRACKEDFILES=1
export PS1='\u@\H \w$(__git_ps1)\$ '
