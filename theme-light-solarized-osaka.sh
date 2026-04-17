#!/bin/sh
THEME=solarized-osaka-light VARIANT=light GHOSTTY_THEME=solarized-osaka-day VIM_THEME=solarized-osaka-day VSCODE_THEME="Solarized Osaka Day"
SCRIPT_DIR="$(cd "$(dirname "$(readlink "$0" || echo "$0")")" && pwd)"
. "$SCRIPT_DIR/theme.sh"
