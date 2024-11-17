#!/bin/bash

# Set the base directory
BASE_DIR="$HOME/dotfiles"

# Loop
for die in "$BASE_DIR"/*/; do
	# Check if it's a directory
	if [[ -d "$dir" ]]; then
		# Get only the directory name without slashes
		config_name=$(basename "$dir")
		echo "Stowing $config..."

		stow "$config" -d "$BASE_DIR" -t "$HOME"
	fi
done

echo "Stowed all configs to '$HOME'/.config!"
