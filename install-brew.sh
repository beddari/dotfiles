#!/bin/sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH (needed after a fresh install)
if ! command -v brew >/dev/null 2>&1; then
  case "$(uname)" in
    Darwin) prefix=/opt/homebrew ;;
    Linux)  prefix=/home/linuxbrew/.linuxbrew ;;
  esac
  [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)"
fi

brew bundle --file="$DOTFILES/Brewfile.$(uname)"
