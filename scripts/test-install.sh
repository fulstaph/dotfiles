#!/usr/bin/env zsh
# Verifies dry-run is read-only and existing directory symlinks are replaced.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

dry_home="$TEST_DIR/dry-home"
output=$(HOME="$dry_home" BREW_CANDIDATES="$TEST_DIR/missing-brew" \
  zsh "$DOTFILES/scripts/install.zsh" --packages --dry-run)

if [[ "$output" != *"[dry] would install Homebrew"* ]]; then
  print -u2 -- "FAIL: expected no-Homebrew dry-run branch, got: $output"
  exit 1
fi

if [[ -e "$dry_home" ]]; then
  print -u2 -- "FAIL: dry-run created the destination home directory"
  exit 1
fi

test_home="$TEST_DIR/home"
old_nvim="$TEST_DIR/old-nvim"
mkdir -p "$test_home/.config" "$old_nvim"
ln -s "$old_nvim" "$test_home/.config/nvim"
HOME="$test_home" zsh "$DOTFILES/scripts/install.zsh" >/dev/null
for plugin in zellij_forgot.wasm zellij_command_palette.wasm zjstatus.wasm SHA256SUMS; do
  if [[ ! -L "$test_home/.config/zellij/plugins/$plugin" ]]; then
    print -u2 -- "FAIL: expected Zellij plugin link for $plugin"
    exit 1
  fi
done

if [[ "$(readlink "$test_home/.config/nvim")" != "$DOTFILES/nvim" || -e "$old_nvim/nvim" ]]; then
  print -u2 -- "FAIL: installer followed the previous Neovim directory symlink"
  exit 1
fi

HOME="$test_home" zsh "$DOTFILES/scripts/install.zsh" >/dev/null
print -- "PASS: installer dry-run, directory symlink replacement, and repeated installation"
