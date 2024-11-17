#!/bin/bash

# File containing the list of packages
PACKAGE_FILE="packages.txt"

# Check if package file exists
if [[ ! -f "$PACKAGE_FILE" ]]; then
	echo "Package file '$PACKAGES_FILE' not found!"
	exit 1
fi

# Read each line from the file and install it
while read -r package_name package_version || [ -n "$package_name" ]; do
	# Ignore empty lines and comments
	[[ -z "$package_name" || "$package_name" =~ ^# ]] && continue

	# Install package with the version (if specified)
	if [[ -n "$package_version" ]]; then
		echo "Installing $package_name version $package_version..."
		paru -S --noconfirm "${package_name}=${package_version}"
	else
		echo "Installing latest version of $package_name..."
		paru -S --noconfirm "$package_name"
	fi
done < "$PACKAGE_FILE"

echo "All packages installed successfully!"
