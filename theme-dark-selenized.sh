#!/bin/sh
THEME=selenized-dark VARIANT=dark GHOSTTY_THEME=selenized-dark VIM_THEME=selenized-dark VSCODE_THEME="Darkerized Better Selenized Dark"
SCRIPT_DIR="$(cd "$(dirname "$(readlink "$0" || echo "$0")")" && pwd)"
. "$SCRIPT_DIR/theme.sh"
