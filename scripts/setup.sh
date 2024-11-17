#!/bin/bash

# This script is used to bootstrap a new Arch Linux machine with my dotfiles and other configurations/apps
echo "Installing rust and cargo via rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Install paru AUR helper..."
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Install the necessary apps
echo "Installing necessary packages and apps..."
./install_packages.sh

echo "Installing TPM..."
./install_tpm.sh

echo "Stowing configs..."
./stow_configs.sh
