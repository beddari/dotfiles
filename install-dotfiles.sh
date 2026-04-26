#!/bin/sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

ln() { command ln -sfn "$@"; }

# zsh
ln "$DOTFILES/zshrc" ~/.zshrc

# bash
ln "$DOTFILES/bashrc" ~/.bashrc

# vim
rm -rf ~/.vim/colors
mkdir -p ~/.vim/colors
ln "$DOTFILES/vimrc" ~/.vimrc
for f in "$DOTFILES"/vim-*.vim; do
  name="${f##*/}"
  ln "$f" ~/.vim/colors/"${name#vim-}"
done

# git
ln "$DOTFILES/gitconfig.local" ~/.gitconfig.local

# ssh
mkdir -p ~/.ssh/hosts ~/.ssh/control
chmod 700 ~/.ssh ~/.ssh/hosts ~/.ssh/control
ln "$DOTFILES/ssh_config" ~/.ssh/config

# ghostty
mkdir -p ~/.config
ln "$DOTFILES/ghostty" ~/.config/ghostty

# starship
ln "$DOTFILES/starship.toml" ~/.config/starship.toml

# vscode
if [ "$(uname)" = "Darwin" ]; then
  VSCODE_DIR="$HOME/Library/Application Support/Code/User"
else
  VSCODE_DIR="$HOME/.config/Code/User"
fi
mkdir -p "$VSCODE_DIR"
ln "$DOTFILES/vscode-keybindings.json" "$VSCODE_DIR/keybindings.json"
if [ -f "$VSCODE_DIR/settings.json" ]; then
  # merge: dotfiles baseline wins, local-only keys preserved
  jq -s '.[0] * .[1]' "$VSCODE_DIR/settings.json" "$DOTFILES/vscode-settings.json" > "$VSCODE_DIR/settings.json.tmp"
  mv "$VSCODE_DIR/settings.json.tmp" "$VSCODE_DIR/settings.json"
else
  cp "$DOTFILES/vscode-settings.json" "$VSCODE_DIR/settings.json"
fi

VSCODE_EXT="$HOME/.vscode/extensions"
mkdir -p "$VSCODE_EXT"
ln "$DOTFILES/vscode-solarized-osaka-night" "$VSCODE_EXT/solarized-osaka-night"
ln "$DOTFILES/vscode-darkerized-better-solarized" "$VSCODE_EXT/darkerized-better-solarized"

# theme scripts
mkdir -p ~/.local/bin
for cmd in theme-dark-solarized-osaka.sh theme-light-solarized-osaka.sh theme-dark-selenized.sh theme-light-selenized.sh; do
  ln "$DOTFILES/$cmd" ~/.local/bin/"$cmd"
done

# set default theme if none active
if [ ! -e "$HOME/.config/delta-theme.gitconfig" ]; then
  "$DOTFILES/theme-dark-solarized-osaka.sh"
fi

# macOS defaults
if [ "$(uname)" = "Darwin" ]; then
  defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

  # ssh-agent launchd service
  PLIST="$HOME/Library/LaunchAgents/com.brew.ssh-agent.plist"
  cp -f "$DOTFILES/com.brew.ssh-agent.plist" "$PLIST"
  launchctl unload "$PLIST" 2>/dev/null || true
  launchctl load "$PLIST"
fi
