#!/bin/sh
THEME=selenized-light VARIANT=light GHOSTTY_THEME=selenized-light VIM_THEME=selenized-light VSCODE_THEME="Darkerized Better Selenized Light"
SCRIPT_DIR="$(cd "$(dirname "$(readlink "$0" || echo "$0")")" && pwd)"
. "$SCRIPT_DIR/theme.sh"
