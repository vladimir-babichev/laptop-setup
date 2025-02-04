#!/usr/bin/env bash

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Bundle install from brew/Brewfile
brew bundle --file brew/Brewfile-system

# Install Zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
zsh -i -c 'zinit self-update'

# Symlink dotfiles
ln -sf "$PWD/dotfiles/{.gitignore,.zshrc}" "$HOME/"

# Configure Firefox plugins
# Configure iTerm
# Configure VSCode
   # Select plugins
   brew bundle --file brew/Brewfile-vscode
   # Keybindings
   # Settings
