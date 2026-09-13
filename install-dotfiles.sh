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
ln "$DOTFILES/gitconfig" ~/.gitconfig

# ssh
mkdir -p ~/.ssh/hosts ~/.ssh/control
chmod 700 ~/.ssh ~/.ssh/hosts ~/.ssh/control
ln "$DOTFILES/ssh_config" ~/.ssh/config

# ghostty
mkdir -p ~/.config
ln "$DOTFILES/ghostty" ~/.config/ghostty

# starship
ln "$DOTFILES/starship.toml" ~/.config/starship.toml

# vscodium
if [ "$(uname)" = "Darwin" ]; then
  VSCODIUM_DIR="$HOME/Library/Application Support/VSCodium/User"
else
  VSCODIUM_DIR="$HOME/.config/VSCodium/User"
fi
mkdir -p "$VSCODIUM_DIR"
ln "$DOTFILES/vscode-keybindings.json" "$VSCODIUM_DIR/keybindings.json"
if [ -f "$VSCODIUM_DIR/settings.json" ]; then
  # merge: dotfiles baseline wins, local-only keys preserved
  jq -s '.[0] * .[1]' "$VSCODIUM_DIR/settings.json" "$DOTFILES/vscode-settings.json" > "$VSCODIUM_DIR/settings.json.tmp"
  mv "$VSCODIUM_DIR/settings.json.tmp" "$VSCODIUM_DIR/settings.json"
else
  cp "$DOTFILES/vscode-settings.json" "$VSCODIUM_DIR/settings.json"
fi

# VSCodium keeps extensions in .vscode-oss (dataFolderName), not .vscode
VSCODIUM_EXT="$HOME/.vscode-oss/extensions"
mkdir -p "$VSCODIUM_EXT"
ln "$DOTFILES/vscode-solarized-osaka-night" "$VSCODIUM_EXT/solarized-osaka-night"
ln "$DOTFILES/vscode-darkerized-better-solarized" "$VSCODIUM_EXT/darkerized-better-solarized"

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
