# Mac Setup Automation

An Ansible-based automation tool for setting up a new Mac environment. This project helps you replicate your development environment across Mac machines.

## Project Structure

```
mac-setup/
├── README.md
├── setup.sh                    # Initial setup script
├── playbooks/
│   ├── main.yml                # Main playbook
│   ├── homebrew.yml            # Homebrew package installation
│   ├── macos.yml               # macOS system preferences
│   ├── dotfiles.yml            # Dotfiles configuration
│   ├── dev-tools.yml           # Development tools setup
│   ├── vscode.yml              # VS Code configuration
│   ├── security.yml            # Security settings
│   └── apps-config.yml         # Application configurations
├── files/
│   ├── dotfiles/               # Configuration files (git-ignored)
│   └── private/                # Private data files (git-ignored)
└── examples/                   # Example templates for private files
```

## Setup Instructions

### 1. On Your Current Mac

1. Clone or create the project
```bash
mkdir mac-setup && cd mac-setup
git init
```

2. Collect dotfiles
```bash
mkdir -p files/dotfiles
for file in .gitconfig .zshrc .vimrc .bash_profile .bashrc .profile .zprofile .zshenv .p10k.zsh .tmux.conf .ideavimrc .gemrc .npmrc .tool-versions; do
  if [ -f ~/$file ]; then
    cp ~/$file files/dotfiles/${file#.}
    echo "Copied $file"
  fi
done
```

3. Export current environment data to private directory
```bash
mkdir -p files/private

# Export Homebrew packages
brew leaves > files/private/brew-leaves.txt
brew list --cask > files/private/brew-casks.txt

# Export version information
ruby -v > files/private/ruby-version.txt
python -v > files/private/python-version.txt
node -v > files/private/node-version.txt
rbenv versions > files/private/rbenv-versions.txt
nvm ls > files/private/nvm-versions.txt

# Export VS Code extensions
code --list-extensions > files/private/vscode-extensions.txt

# Export macOS defaults (optional)
defaults read > files/private/macos-defaults.txt
```

4. Copy SSH configuration (if needed)
```bash
mkdir -p files/private/ssh
cp -r ~/.ssh/config files/private/ssh/
# Note: Be careful with SSH keys - consider transferring them separately
```

### 2. Transfer to New Mac

Choose one of the following methods to transfer the project:

- AirDrop
- USB drive
- rsync command
```bash
rsync -av mac-setup/ newmac:~/mac-setup/
```

### 3. Setup on New Mac

1. Run the initial setup script
```bash
cd mac-setup
chmod +x setup.sh
./setup.sh
```

2. Execute Ansible playbooks
```bash
ansible-playbook playbooks/main.yml
```

## Playbook Details

### homebrew.yml
- Installs Homebrew packages and applications
- Adds taps
- Updates packages

### macos.yml
- Configures macOS system preferences
- Sets up Mission Control and Hot Corners
- Configures application space bindings

### dotfiles.yml
- Copies configuration files
- Creates necessary directories
- Configures shell settings

### dev-tools.yml
- Sets up development environments (Node.js, Ruby, etc.)
- Configures language-specific tools

### vscode.yml
- Installs VS Code extensions
- Configures editor settings

### security.yml
- Sets up SSH keys and configurations
- Configures security settings

### apps-config.yml
- Configures application preferences

## Security Considerations

- The `files/dotfiles/` and `files/private/` directories are git-ignored to prevent sensitive information from being committed
- Transfer configuration files containing sensitive information through secure methods
- Handle SSH keys and credentials separately
- Review all configuration files before running playbooks to ensure no sensitive data is exposed

## Private Data Management

The `files/private/` directory is designed to store all personal and sensitive information that should not be committed to the repository. This includes:

- API keys and tokens
- Personal configuration data
- Environment-specific settings
- Version information
- SSH configurations
- Application preferences with sensitive data

When sharing this repository, ensure that the `files/private/` directory is properly excluded from Git tracking via the `.gitignore` file.

## Important Notes

- Review configuration files before running playbooks
- Backup existing configurations as they may be overwritten
- Some applications may require manual configuration on first launch
- Ensure sensitive information is handled securely

## Prerequisites

- macOS (tested on Ventura and later)
- Basic understanding of terminal operations
- Administrator privileges on the target Mac

## Customization

You can customize the installation by modifying:
- `homebrew.yml` for different packages and applications
- `dotfiles.yml` for different configuration files
- `macos.yml` for different system preferences
- Add new playbooks for additional setup tasks

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is open source and available under the [MIT License](LICENSE).