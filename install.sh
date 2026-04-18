#!/bin/sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

sh "$DOTFILES/install-brew.sh"
sh "$DOTFILES/install-dotfiles.sh"

echo "Done."

