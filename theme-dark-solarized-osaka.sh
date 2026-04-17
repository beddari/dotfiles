#!/bin/sh
THEME=solarized-osaka-dark VARIANT=dark GHOSTTY_THEME=solarized-osaka-night VIM_THEME=solarized-osaka-night VSCODE_THEME="Solarized Osaka Night"
SCRIPT_DIR="$(cd "$(dirname "$(readlink "$0" || echo "$0")")" && pwd)"
. "$SCRIPT_DIR/theme.sh"
