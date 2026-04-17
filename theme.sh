#!/bin/sh
# Shared theme switching logic — sourced by theme-*.sh scripts
set -e

if [ -z "$THEME" ]; then
  echo "Usage: theme-dark-solarized-osaka.sh | theme-light-solarized-osaka.sh"
  echo "       theme-dark-selenized.sh       | theme-light-selenized.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$(readlink "$0" || echo "$0")")" && pwd)"
DOTFILES="$SCRIPT_DIR"

# 1. Delta git config (included by gitconfig.local)
mkdir -p "$HOME/.config"
ln -sfn "$DOTFILES/delta-$THEME.gitconfig" "$HOME/.config/delta-theme.gitconfig"

# 2. Ghostty config and reload
echo "theme = $GHOSTTY_THEME" > "$DOTFILES/ghostty/config"
killall -USR2 ghostty 2>/dev/null || true

# 3. Dircolors
ln -sf "$DOTFILES/dircolors.$VARIANT" "$HOME/.dircolors"

# 4. Vim colorscheme
mkdir -p "$HOME/.vim"
echo "colorscheme $VIM_THEME" > "$HOME/.vim/theme.vim"

# 5. VS Code color theme
if [ "$(uname)" = "Darwin" ]; then
  VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
else
  VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
fi
if [ -f "$VSCODE_SETTINGS" ]; then
  tmp=$(mktemp)
  sed "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$VSCODE_THEME\"/" "$VSCODE_SETTINGS" > "$tmp"
  mv "$tmp" "$VSCODE_SETTINGS"
fi

echo "Switched to $THEME"
