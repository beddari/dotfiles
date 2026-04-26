#!/bin/sh
# Configure a red warning prompt for the root shell on macOS and Linux.
# Sets a red PS1 and a dark red terminal background (via OSC 11) so it's
# immediately obvious when running as root.
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

OS="$(uname)"

if [ "$OS" = "Darwin" ]; then
  ROOT_PROFILE=/var/root/.profile
elif [ "$OS" = "Linux" ]; then
  ROOT_PROFILE=/root/.bashrc
else
  echo "Unsupported OS: $OS"
  exit 1
fi

tee "$ROOT_PROFILE" > /dev/null <<'EOF'
# root-prompt: red PS1 + dark red terminal background
_R=$(printf '\033[1;31m')
_X=$(printf '\033[0m')
PS1="[${_R}root${_X}] \$PWD > "
unset _R _X
printf '\033]11;#2a0000\007'
trap 'printf "\033]111\007"' EXIT
EOF

echo "Done. Root prompt configured in $ROOT_PROFILE"
