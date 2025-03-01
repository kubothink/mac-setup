#!/bin/bash
# dotfilesディレクトリを作成
mkdir -p files/dotfiles

# 基本的な設定ファイルをコピー（シンボリックリンクの実体も追跡）
for file in .gitconfig .zshrc .vimrc .bash_profile .bashrc .profile .zprofile .zshenv .p10k.zsh .tmux.conf .ideavimrc .gemrc .npmrc .tool-versions; do
  if [ -f ~/$file ] || [ -L ~/$file ]; then
    cp -L ~/$file files/dotfiles/${file#.}
    echo "Copied $file"
  fi
done

# .configディレクトリ内の重要な設定ファイルディレクトリをコピー
CONFIG_DIRS=("nvim" "git" "karabiner" "alacritty" "kitty" "starship" "bat" "iterm2" "fish")
for dir in "${CONFIG_DIRS[@]}"; do
  if [ -d ~/.config/$dir ]; then
    mkdir -p files/dotfiles/config/$dir
    cp -RL ~/.config/$dir/* files/dotfiles/config/$dir/ 2>/dev/null || true
    echo "Copied .config/$dir"
  fi
done

# その他の重要なアプリケーション設定
if [ -d ~/Library/Application\ Support/Code/User ]; then
  mkdir -p "files/dotfiles/vscode"
  cp -L ~/Library/Application\ Support/Code/User/settings.json files/dotfiles/vscode/ 2>/dev/null || true
  cp -L ~/Library/Application\ Support/Code/User/keybindings.json files/dotfiles/vscode/ 2>/dev/null || true
  echo "Copied VS Code settings"
fi