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

# source usr local virtualenvwrapper, if present
[[ -f "/usr/local/bin/virtualenvwrapper.sh" ]] && {
  export WORKON_HOME=~/.virtualenvs
  export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
  source "/usr/local/bin/virtualenvwrapper.sh"
}

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
osuser() {
  VIRTUAL_ENV_DISABLE_PROMPT=1 workon oscli
  source <(PASSWORD_STORE_DIR=$HOME/.pass-team/ pass show "home/$USER/$1/user")
}
osoperator() {
  VIRTUAL_ENV_DISABLE_PROMPT=1 workon oscli
  source <(PASSWORD_STORE_DIR=$HOME/.pass-team/ pass show "home/$USER/$1/operator")
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
osadmin() {
  VIRTUAL_ENV_DISABLE_PROMPT=1 workon oscli
  source <(PASSWORD_STORE_DIR=$HOME/.pass-team/ pass show "openstack/$1/admin")
  echo "WARNING: THIS ACCOUNT HAS SUPER COW POWERS, DO NOT USE UNLESS NEEDED!"
}
oslogout() {
  unset OS_AUTH_URL OS_IDENTITY_API_VERSION OS_PASSWORD \
        OS_PROJECT_DOMAIN_NAME OS_PROJECT_NAME OS_REGION_NAME \
        OS_USERNAME OS_USER_DOMAIN_NAME
  deactivate
}
osprompt() {
  export PS1__OS_SAVE="${PS1__OS_SAVE:-$PS1}"
  [[ -n $OS_REGION_NAME || -n $OS_USERNAME || -n $OS_PROJECT_NAME ]] && {
    [[ $OS_USERNAME == "admin" ]] && attrib="\e[31m" || \
    [[ $OS_USERNAME =~ .*@operator$ ]] && attrib="\e[32m" || attrib=""
    PS1="($OS_REGION_NAME/\[$attrib\]$OS_USERNAME\[\e[m\]/$OS_PROJECT_NAME) $PS1__OS_SAVE"
  } || PS1=$PS1__OS_SAVE
}

# ansible
export ANSIBLE_DIR=$HOME/work/ansible
export ANSIBLE_ROLES_PATH=$ANSIBLE_DIR/roles:$ANSIBLE_DIR/vendor/roles
export ANSIBLE_FILTER_PLUGINS=~/work/ansible/filter_plugins
export ANSIBLE_TEST_PLUGINS=~/work/ansible/test_plugins

