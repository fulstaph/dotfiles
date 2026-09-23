#!/usr/bin/env zsh
# Verifies --packages reaches the no-Homebrew dry-run branch under errexit.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

output=$(BREW_CANDIDATES="$TEST_DIR/missing-brew" \
  zsh "$DOTFILES/scripts/install.zsh" --packages --dry-run)

if [[ "$output" != *"[dry] would install Homebrew"* ]]; then
  print -u2 -- "FAIL: expected no-Homebrew dry-run branch, got: $output"
  exit 1
fi

test_home="$TEST_DIR/home"
HOME="$test_home" zsh "$DOTFILES/scripts/install.zsh" >/dev/null
for plugin in zellij_forgot.wasm zjstatus.wasm SHA256SUMS; do
  if [[ ! -L "$test_home/.config/zellij/plugins/$plugin" ]]; then
    print -u2 -- "FAIL: expected Zellij plugin link for $plugin"
    exit 1
  fi
done

print -- "PASS: installer handles a missing Homebrew binary and links Zellij plugins"
