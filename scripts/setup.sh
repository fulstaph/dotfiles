#!/bin/bash

# This script is used to bootstrap a new Arch Linux machine
# with my dotfiles and other configurations/apps

set -e # Exit immediately if a command exits with a non-zero status

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"

# Check if required commands exist
for cmd in "lsb_release" "git" "curl"; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd command not found"
        exit 1
    fi
done

OS=$(lsb_release -si)
echo "Operating System: $OS"

if [ "$OS" != "Arch" ] && [ "$OS" != "EndeavourOS" ]; then
    echo "This script is only for Arch Linux for now. Exiting..."
    exit 1
fi


DISTRO="arch" # Default to Arch Linux for now
DOTFILES_DIR=$HOME/dotfiles
SCRIPTS_DIR=$DOTFILES_DIR/scripts

LAPTOP_HOSTNAME="thinkpad"
DESKTOP_HOSTNAME="homepc"

echo "Installing rust and cargo via rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Installing GHCup..."
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

if [ "$DISTRO" = "arch" ]; then
    # TODO: Use a temporary directory to clone the repo
    echo "Install paru AUR helper..."
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si

    cd
fi

# Install the necessary apps
echo "Installing necessary packages and apps..."
"$SCRIPTS_DIR"/install_packages.sh

echo "Generating background picture for lockscreen..."
betterlockscreen -u "$DOTFILES_DIR"/wallpaper/3840x2160.jpg

echo "Installing TPM..."
"$SCRIPTS_DIR"/install_tpm.sh

echo "Stowing configs..."
"$SCRIPTS_DIR"/stow_configs.sh

echo "Setting up zsh using zinit..."
"$SCRIPTS_DIR"/zinit_install.sh

echo "Starting docker service..."
sudo systemctl start docker.service
sudo systemctl enable docker.service

# Setup Ly
sudo systemctl enable ly.service
sudo systemctl start ly.service

# Add user to docker group to use it without sudo
if ! getent group docker &> /dev/null; then
    echo "Creating docker group..."
    sudo groupadd docker
fi
sudo usermod -aG docker $USER
newgrp docker

# Configure TLP only on my laptop
if [ "$(hostname)" = "$LAPTOP_HOSTNAME" ]; then
    echo "Configure TLP..."
    "$SCRIPTS_DIR"/enable_tlp.sh
fi

echo "Setup complete!"
