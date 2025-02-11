#!/bin/zsh

echo "Starting initial macOS setup..."

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

echo "\nInitial setup completed!"
echo "You can now run the Ansible playbook with:"
echo "ansible-playbook playbooks/homebrew.yml"
