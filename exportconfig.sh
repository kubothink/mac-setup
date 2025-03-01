#!/bin/bash
# 環境設定データのエクスポート先ディレクトリを作成
mkdir -p files/private

# Homebrewパッケージのエクスポート
echo "Exporting Homebrew packages..."
brew leaves > files/private/brew-leaves.txt
brew list --cask > files/private/brew-casks.txt

# バージョン情報のエクスポート
echo "Exporting version information..."
ruby -v > files/private/ruby-version.txt 2>/dev/null || echo "Ruby not installed" > files/private/ruby-version.txt
python3 -V > files/private/python-version.txt 2>/dev/null || echo "Python3 not installed" > files/private/python-version.txt
node -v > files/private/node-version.txt 2>/dev/null || echo "Node.js not installed" > files/private/node-version.txt
if command -v rbenv &> /dev/null; then
  rbenv versions > files/private/rbenv-versions.txt
else
  echo "rbenv not installed" > files/private/rbenv-versions.txt
fi
if [ -f ~/.nvm/nvm.sh ]; then
  source ~/.nvm/nvm.sh && nvm ls > files/private/nvm-versions.txt
else
  echo "nvm not installed" > files/private/nvm-versions.txt
fi

# VSCodeエクステンションのエクスポート
echo "Exporting VS Code extensions..."
if command -v code &> /dev/null; then
  code --list-extensions > files/private/vscode-extensions.txt
else
  echo "VS Code not installed" > files/private/vscode-extensions.txt
fi

# 重要なmacOS設定のみエクスポート
echo "Exporting macOS settings..."
mkdir -p files/private/macos-defaults
# Dock
defaults read com.apple.dock > files/private/macos-defaults/dock.plist 2>/dev/null || echo "Failed to export Dock settings"
# Finder
defaults read com.apple.finder > files/private/macos-defaults/finder.plist 2>/dev/null || echo "Failed to export Finder settings"
# トラックパッド
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad > files/private/macos-defaults/trackpad.plist 2>/dev/null || echo "Failed to export Trackpad settings"
# キーボード
defaults read com.apple.keyboard > files/private/macos-defaults/keyboard.plist 2>/dev/null || echo "Failed to export Keyboard settings"
# システム環境設定
defaults read com.apple.systempreferences > files/private/macos-defaults/systempreferences.plist 2>/dev/null || echo "Failed to export System Preferences settings"
# スクリーンショット
defaults read com.apple.screencapture > files/private/macos-defaults/screencapture.plist 2>/dev/null || echo "Failed to export Screenshot settings"

echo "Export completed!" 