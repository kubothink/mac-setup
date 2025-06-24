#!/bin/zsh

echo "Starting initial macOS setup..."

# macOSバージョンのチェック
macos_version=$(sw_vers -productVersion)
echo "Detected macOS version: $macos_version"

# Ventura (13.x)以降かチェック
if [[ $(echo $macos_version | cut -d. -f1) -lt 13 ]]; then
  echo "Warning: This script is tested on macOS Ventura (13.x) and later. Some features may not work correctly."
  echo "Do you want to continue? (y/n)"
  read -r continue_setup
  if [[ ! $continue_setup =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
  fi
fi

# 現在の設定をバックアップ
echo "Backing up current settings..."
backup_dir=~/mac-setup-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p $backup_dir
if [ -f ~/.zshrc ]; then
  cp ~/.zshrc $backup_dir/
fi
if [ -f ~/.gitconfig ]; then
  cp ~/.gitconfig $backup_dir/
fi
echo "Backup completed to $backup_dir"

# dotfilesの収集
echo "Collecting dotfiles..."
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

# 環境設定データのエクスポート
echo "Exporting environment configuration..."
mkdir -p files/private

# Homebrewパッケージのエクスポート
echo "Exporting Homebrew packages..."
if command -v brew &> /dev/null; then
  brew leaves > files/private/brew-leaves.txt
  brew list --cask > files/private/brew-casks.txt
else
  echo "Homebrew not installed, skipping package export"
fi

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

# SSH設定のコピー
echo "Copying SSH configuration..."
mkdir -p files/private/ssh
if [ -f ~/.ssh/config ]; then
  cp ~/.ssh/config files/private/ssh/
  echo "Copied SSH config file"
else
  echo "SSH config file not found, skipping"
fi
echo "NOTE: SSH keys must be manually copied for security reasons"

# Load .zshrc if it exists
if [ -f ~/.zshrc ]; then
    # zshの場合のみsourceを実行
    if [ -n "$ZSH_VERSION" ]; then
        source ~/.zshrc
    else
        echo "Note: .zshrc exists but not sourcing it in non-zsh shell"
    fi
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH based on CPU architecture
    if [[ $(uname -m) == "arm64" ]]; then
        # Apple Silicon Mac
        echo "Configuring Homebrew for Apple Silicon Mac..."
        echo '# Set PATH for Homebrew' >> ~/.zshrc
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel Mac
        echo "Configuring Homebrew for Intel Mac..."
        echo '# Set PATH for Homebrew' >> ~/.zshrc
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Reload shell configuration
    source ~/.zshrc
else
    echo "Homebrew is already installed"
fi

# Install Ansible
echo "Installing Ansible..."
brew install ansible

# Create inventory file if it doesn't exist
if [ ! -f inventory.yml ]; then
    echo "Creating inventory.yml..."
    cat > inventory.yml << 'EOL'
all:
  hosts:
    localhost:
      ansible_connection: local
EOL
fi

# Create ansible.cfg if it doesn't exist
if [ ! -f ansible.cfg ]; then
    echo "Creating ansible.cfg..."
    cat > ansible.cfg << 'EOL'
[defaults]
inventory = inventory.yml
host_key_checking = False
EOL
fi

echo "\nInitial setup completed!"
echo "Next steps:"
echo "1. Review playbooks in the playbooks/ directory"
echo "2. Customize variables and settings as needed"
echo "3. Run the main playbook with: ansible-playbook playbooks/main.yml"
echo "   Or run individual playbooks like: ansible-playbook playbooks/homebrew.yml"
echo "4. Check examples/manual_checklist.md for additional manual steps"
