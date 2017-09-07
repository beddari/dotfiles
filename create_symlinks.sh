#!/bin/bash
ln -sf ~/dotfiles/bashrc ~/.bashrc
ln -sf ~/dotfiles/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
mkdir -p ~/.vim/colors
ln -sf ~/dotfiles/vim_colors_solarized.vim ~/.vim/colors/solarized.vim
ln -sf ~/dotfiles/vimrc ~/.vimrc
ln -sf ~/dotfiles/dircolors.ansi-dark ~/.dir_colors
mkdir -p ~/.config/Code/User
ln -sf ~/dotfiles/vscode.json ~/.config/Code/User/settings.json
