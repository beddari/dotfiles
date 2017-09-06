# Source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# gpg
if [[ $(command -v gpg2) ]]; then
  alias gpg="gpg2"
fi

alias lsvirtualenv="lsvirtualenv -b"
alias work="cd $HOME/work"
eval "$(hub alias -s)"

export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=10000

export GOPATH=$HOME/src/golang

export VISUAL=vim
export EDITOR="$VISUAL"

# Set correct libvirt virsh connect URI (which isn't the default)
# http://wiki.libvirt.org/page/FAQ#What_is_the_difference_between_qemu:.2F.2F.2Fsystem_and_qemu:.2F.2F.2Fsession.3F_Which_one_should_I_use.3F
export LIBVIRT_DEFAULT_URI="qemu:///system"

git_osx=/usr/local/etc/bash_completion.d
if [[ -d $git_osx ]]; then
  source /usr/local/etc/bash_completion.d/git-completion.bash
  source /usr/local/etc/bash_completion.d/git-prompt.sh
fi

linux_gitprompt=/usr/share/doc/git/contrib/completion/git-prompt.sh
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

# team password store
alias tpass="PASSWORD_STORE_DIR=$HOME/.pass-team/ pass"
# team openstack credentials
osadmin() {
  workon oscli
  source <(tpass show "openstack/$1/admin")
}
osuser() {
  workon oscli
  source <(tpass show "$(whoami)/openstack/$1")
}
osproject() {
  export OS_PROJECT_NAME="$1"
  export OS_PROJECT_DOMAIN_NAME="${1#*.}"
  openstack token issue >/dev/null && {
    echo "Authenticated successfully."
  } || {
    echo "Authentication failed."
  }
}

