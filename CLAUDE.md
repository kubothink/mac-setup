# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Mac setup automation project using Ansible to configure a new Mac environment. The project helps replicate development environments across Mac machines by automating package installation, system preferences, dotfiles deployment, and application configuration.

## Core Commands

### Initial Setup (on current Mac)
```bash
chmod +x setup.sh
./setup.sh
```
This script backs up current settings, exports environment configuration, and installs required dependencies.

### Running the Full Setup (on new Mac)
```bash
# Install Xcode Command Line Tools first
xcode-select --install

# Run setup script
chmod +x setup.sh
./setup.sh

# Execute all playbooks
ansible-playbook playbooks/main.yml
```

### Individual Playbook Commands
```bash
# Run specific playbooks
ansible-playbook playbooks/homebrew.yml      # Install packages
ansible-playbook playbooks/macos.yml         # System preferences
ansible-playbook playbooks/dotfiles.yml      # Configuration files
ansible-playbook playbooks/dev-tools.yml     # Development environments
ansible-playbook playbooks/vscode.yml        # VS Code setup
ansible-playbook playbooks/security.yml      # Security settings
ansible-playbook playbooks/apps-config.yml   # Application configurations
```

### Homebrew Path Setup (if needed)
```bash
# For Apple Silicon Macs
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel Macs
eval "$(/usr/local/bin/brew shellenv)"
```

## Project Architecture

### Directory Structure
- `setup.sh` - Main initialization script that collects current environment and installs dependencies
- `playbooks/` - Ansible playbooks for different configuration aspects
  - `main.yml` - Master playbook that orchestrates all others
  - Individual playbooks for homebrew, macOS, dotfiles, dev-tools, vscode, security, apps-config
- `files/dotfiles/` - Personal configuration files (git-ignored for security)
- `files/private/` - Private data files including package lists and versions (git-ignored)
- `examples/` - Template files and manual checklist
- `inventory.yml` - Ansible inventory (targets localhost)
- `ansible.cfg` - Ansible configuration

### Key Scripts and Utilities
- `exportconfig.sh` - Exports current environment configuration
- `copydotfiles.sh` - Copies dotfiles from home directory
- `apply_config.sh` - Applies collected configuration to new system

### Workflow
1. **Collection Phase**: `setup.sh` backs up and exports current Mac configuration
2. **Transfer Phase**: Project transferred to new Mac via AirDrop, USB, or Git
3. **Application Phase**: Ansible playbooks apply collected configuration to new Mac

## Development Notes

### Security Considerations
- `files/dotfiles/` and `files/private/` are git-ignored to prevent sensitive data commits
- SSH keys must be manually transferred for security
- Configuration files should be reviewed before running playbooks

### Supported macOS Versions
- Tested on macOS Ventura (13.x) and later
- Script warns for older versions but allows continuation

### Architecture Detection
The setup script automatically detects Apple Silicon vs Intel Macs and configures Homebrew paths accordingly.

### Error Handling
If Ansible commands fail after setup, check:
1. Homebrew installation and PATH configuration
2. Xcode Command Line Tools installation
3. Ansible installation via `brew install ansible`