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

# Load .zshrc if it exists
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
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
