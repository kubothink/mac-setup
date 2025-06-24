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

Run the setup script to collect your current environment configuration:

```bash
chmod +x setup.sh
./setup.sh
```

This script will:
- Back up your current settings
- Collect dotfiles from your home directory
- Export environment configuration (Homebrew packages, versions, etc.)
- Copy SSH configuration (Note: SSH keys must be transferred separately)
- Install Homebrew if not already installed
- Install Ansible

### 2. Transfer to New Mac

Choose one of the following methods to transfer the project:

- AirDrop
- USB drive
- Git repository (private)
- rsync command
```bash
rsync -av mac-setup/ newmac:~/mac-setup/
```

### 3. Setup on New Mac

1. Install Xcode Command Line Tools (required for Homebrew)
```bash
xcode-select --install
```

2. Run the setup script
```bash
cd mac-setup
chmod +x setup.sh
./setup.sh
```

3. If `ansible-playbook` command is not found after running setup.sh:
```bash
# Open a new terminal window, or
# For Apple Silicon Macs
eval "$(/opt/homebrew/bin/brew shellenv)"
# For Intel Macs
eval "$(/usr/local/bin/brew shellenv)"

# Then reinstall Ansible if needed
brew install ansible
```

4. Execute Ansible playbooks
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

## Troubleshooting

### Homebrew or Ansible Not in PATH
After installing Homebrew and Ansible, if commands are not found:

1. Check if Homebrew is installed correctly:
```bash
# For Apple Silicon Macs
ls /opt/homebrew/bin/brew
# For Intel Macs
ls /usr/local/bin/brew
```

2. Update your PATH manually:
```bash
# For Apple Silicon Macs
eval "$(/opt/homebrew/bin/brew shellenv)"
# For Intel Macs
eval "$(/usr/local/bin/brew shellenv)"
```

3. Verify Ansible installation:
```bash
which ansible-playbook
ansible-playbook --version
```

4. If Ansible is not installed, install it manually:
```bash
brew install ansible
```

### Permission Issues
If you encounter permission issues:
```bash
# Fix permissions on Homebrew directories
sudo chown -R $(whoami) $(brew --prefix)/*
```

### Xcode Command Line Tools
If you see errors about missing command line tools:
```bash
xcode-select --install
```

## Security Considerations

- The `files/dotfiles/` and `files/private/` directories are git-ignored to prevent sensitive information from being committed
- Transfer configuration files containing sensitive information through secure methods
- Handle SSH keys and credentials separately
- Review all configuration files before running playbooks to ensure no sensitive data is exposed

## Manual Configuration Checklist

After running the automated setup, check `examples/manual_checklist.md` for important settings that need to be configured manually.

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