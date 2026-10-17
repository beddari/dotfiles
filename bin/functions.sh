root="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"

# Where VSCodium keeps its user settings on this platform.
if [[ "$(uname -s)" == "Darwin" ]]; then
	vscodium_dir="$HOME/Library/Application Support/VSCodium/User"
else
	vscodium_dir="$HOME/.config/VSCodium/User"
fi

# VSCodium keeps extensions in .vscode-oss, its dataFolderName, not .vscode.
vscodium_ext="$HOME/.vscode-oss/extensions"

# Where sops reads age identities from without being told: keys.txt here.
# On the Mac, shellrc sets XDG_CONFIG_HOME so that sops looks here too.
sops_age_dir="${XDG_CONFIG_HOME:-$HOME/.config}/sops/age"

# The keyring the brave-keyring package ships, and apt/ holds a copy of.
brave_keyring="brave-browser-archive-keyring.gpg"

#
# Prints a log message.
#
function log()
{
	if [[ -t 1 ]]; then
		echo -e "\x1b[1m\x1b[32m>>>\x1b[0m \x1b[1m$1\x1b[0m"
	else
		echo ">>> $1"
	fi
}

#
# Prints an error message.
#
function error()
{
	if [[ -t 2 ]]; then
		echo -e "\x1b[1m\x1b[31m!!!\x1b[0m \x1b[1m$1\x1b[0m" >&2
	else
		echo "!!! $1" >&2
	fi
}

#
# Prints an error message and exits.
#
function fail()
{
	error "$1"
	exit 1
}

#
# Checks that the script runs as root, for the tasks that change the system.
#
function check_root()
{
	[[ "$(id -u)" -eq 0 ]] && return

	error "Run it as root: sudo $0"
	return 1
}

#
# Prints the links that "task link" makes, one per line: the file in this
# repository, then the link in the home directory. The link comes last since
# it may have spaces in it.
#
function links()
{
	cat <<EOF
home/zshrc $HOME/.zshrc
home/bashrc $HOME/.bashrc
home/gitconfig $HOME/.gitconfig
home/ssh_config $HOME/.ssh/config
home/starship.toml $HOME/.config/starship.toml
vim/vimrc $HOME/.vimrc
vim/colors $HOME/.vim/colors
ghostty $HOME/.config/ghostty
vscodium/keybindings.json $vscodium_dir/keybindings.json
vscodium/extensions/darkerized-better-solarized $vscodium_ext/darkerized-better-solarized
vscodium/extensions/solarized-osaka-night $vscodium_ext/solarized-osaka-night
local/bin/theme $HOME/.local/bin/theme
EOF
	if [[ "$(uname -s)" == "Darwin" ]]; then
		echo "local/bin/ssh-enclave $HOME/.local/bin/ssh-enclave"
		echo "local/bin/ssh-agent-launchd $HOME/.local/bin/ssh-agent-launchd"
	fi
}

#
# Prints the settings in gnome/settings, one per line: schema, key, then the
# value, which may have spaces in it. Comments and blank lines are left out.
#
function gnome_settings()
{
	grep -v '^[[:space:]]*\(#\|$\)' "$root/gnome/settings"
}

