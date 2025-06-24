#!/bin/zsh

echo "Starting configuration application..."

# 基本ディレクトリのセットアップ
echo "Setting up basic directories..."
mkdir -p ~/.config
mkdir -p ~/.local/share/zsh
mkdir -p ~/.ssh

# dotfilesの配置
echo "Applying dotfiles..."
if [ -d files/dotfiles ]; then
  # 基本設定ファイル
  for file in $(find files/dotfiles -maxdepth 1 -type f); do
    filename=$(basename "$file")
    if [[ "$filename" != "config" && "$filename" != "vscode" ]]; then
      cp -v "$file" "$HOME/.$filename"
      echo "Copied $filename to $HOME/.$filename"
    fi
  done

  # .configディレクトリの設定
  if [ -d files/dotfiles/config ]; then
    for dir in $(find files/dotfiles/config -maxdepth 1 -mindepth 1 -type d); do
      dirname=$(basename "$dir")
      mkdir -p "$HOME/.config/$dirname"
      cp -Rv "$dir"/* "$HOME/.config/$dirname"/ 2>/dev/null || true
      echo "Copied config for $dirname"
    done
  fi

  # VSCode設定
  if [ -d files/dotfiles/vscode ]; then
    mkdir -p "$HOME/Library/Application Support/Code/User"
    cp -v files/dotfiles/vscode/settings.json "$HOME/Library/Application Support/Code/User/" 2>/dev/null || true
    cp -v files/dotfiles/vscode/keybindings.json "$HOME/Library/Application Support/Code/User/" 2>/dev/null || true
    echo "Copied VS Code settings"
  fi
fi

# プライベート設定の配置
echo "Applying private configurations..."
if [ -d files/private ]; then
  # SSH設定
  if [ -d files/private/ssh ]; then
    cp -v files/private/ssh/config ~/.ssh/ 2>/dev/null || true
    chmod 600 ~/.ssh/config 2>/dev/null || true
    echo "Copied SSH config"
    echo "SECURITY NOTICE: SSH keys must be manually copied for security reasons."
  fi

  # VSCodeエクステンション
  if [ -f files/private/vscode-extensions.txt ]; then
    if command -v code &> /dev/null; then
      echo "Installing VS Code extensions..."
      while read extension; do
        if [[ ! -z "$extension" ]]; then
          code --install-extension "$extension" || echo "Failed to install $extension"
        fi
      done < files/private/vscode-extensions.txt
    else
      echo "VS Code not installed, skipping extensions installation"
    fi
  fi

  # macOS設定の適用
  if [ -d files/private/macos-defaults ]; then
    echo "Applying macOS settings..."
    echo "Note: Some settings may require admin rights or a restart to take effect."
    
    # いくつかの基本的なmacOS設定を適用（完全なものではありません）
    # Dock設定
    if [ -f files/private/macos-defaults/dock.plist ]; then
      defaults import com.apple.dock - < files/private/macos-defaults/dock.plist 2>/dev/null || echo "Failed to import Dock settings"
      killall Dock 2>/dev/null || true
    fi
    
    # Finder設定
    if [ -f files/private/macos-defaults/finder.plist ]; then
      defaults import com.apple.finder - < files/private/macos-defaults/finder.plist 2>/dev/null || echo "Failed to import Finder settings"
      killall Finder 2>/dev/null || true
    fi
    
    # スクリーンショット設定
    if [ -f files/private/macos-defaults/screencapture.plist ]; then
      defaults import com.apple.screencapture - < files/private/macos-defaults/screencapture.plist 2>/dev/null || echo "Failed to import Screenshot settings"
      killall SystemUIServer 2>/dev/null || true
    fi
  fi
fi

# Homebrew関連の設定
if [ -f files/private/brew-leaves.txt ] && command -v brew &> /dev/null; then
  echo "Installing Homebrew packages..."
  echo "This may take some time..."
  
  # タップを追加
  brew tap homebrew/cask-fonts 2>/dev/null || true
  
  # 通常のパッケージをインストール
  while read package; do
    if [[ ! -z "$package" ]]; then
      brew install "$package" || echo "Failed to install $package"
    fi
  done < files/private/brew-leaves.txt
  
  # Caskパッケージをインストール
  if [ -f files/private/brew-casks.txt ]; then
    while read cask; do
      if [[ ! -z "$cask" ]]; then
        brew install --cask "$cask" || echo "Failed to install cask $cask"
      fi
    done < files/private/brew-casks.txt
  fi
else
  echo "Homebrew not installed or package list not found, skipping package installation"
fi

# zshをデフォルトシェルに設定
if [ "$SHELL" != "/bin/zsh" ]; then
  echo "Setting zsh as default shell..."
  chsh -s /bin/zsh
fi

echo "Configuration applied successfully!"
echo "Note: Some settings may require a system restart to take effect."
echo "Please check examples/manual_checklist.md for additional manual steps." 