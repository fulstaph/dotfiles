#!/usr/bin/env bash
# scripts/test-zshrc-mac.sh
# Tests that zshrc sources cleanly on macOS.
# Assumes Homebrew is available (pre-installed on CI runners and real machines).
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

# ── Install tools ──────────────────────────────────────────────────────────
echo "==> Installing tools via Homebrew..."
brew install --quiet \
  eza zoxide starship fzf bat fd \
  zsh-autosuggestions zsh-syntax-highlighting

echo ""
echo "=== tool versions ==="
printf "  zsh:      %s\n" "$(zsh --version)"
printf "  eza:      %s\n" "$(eza --version 2>/dev/null | head -1 || echo MISSING)"
printf "  zoxide:   %s\n" "$(zoxide --version 2>/dev/null || echo MISSING)"
printf "  starship: %s\n" "$(starship --version 2>/dev/null | head -1 || echo MISSING)"
printf "  fzf:      %s\n" "$(fzf --version 2>/dev/null || echo MISSING)"
echo ""

# Isolated temp home — never touches the real one
TESTHOME=$(mktemp -d)
trap 'rm -rf "$TESTHOME"' EXIT

cp "$DOTFILES/zsh/.zshrc" "$TESTHOME/.zshrc"
cp "$DOTFILES/zsh/.zprofile" "$TESTHOME/.zprofile"
cp "$DOTFILES/zsh/.zshenv" "$TESTHOME/.zshenv"
mkdir -p "$TESTHOME/.config"
cp "$DOTFILES/starship/starship.toml" "$TESTHOME/.config/starship.toml"

echo "=== sourcing zsh configuration ==="
OUTPUT=$(TERM=xterm-256color HOME="$TESTHOME" zsh --no-rcs -c '
  source "$HOME/.zshenv"
  source "$HOME/.zprofile"
  source "$HOME/.zshrc"
  echo "OK:ALIASES:$(alias | wc -l | tr -d " ")"
  echo "OK:CD_TYPE:$(type cd | head -1)"
  echo "OK:OS_VAR:$OS"
  echo "OK:BREW:${BREW:-none}"
  echo "OK:STARSHIP:$(command -v starship >/dev/null && starship --version | head -1 || echo MISSING)"
  echo "OK:EZA:$(command -v eza >/dev/null && eza --version | head -1 || echo MISSING)"
  echo "OK:ZOXIDE:$(command -v zoxide >/dev/null && zoxide --version || echo MISSING)"
  echo "OK:FZF:$(fzf --version 2>/dev/null || echo MISSING)"
' 2>&1 | grep -v 'not interactive\|compinit\|compdef\|can.t change option\|dumb.*terminal')

echo "$OUTPUT"
echo ""

FAILS=$(echo "$OUTPUT" | grep -E '(^zsh[^:]*:[0-9]+: |\.(zshenv|zshrc|zprofile):)' | grep -v 'compinit\|compdef' || true)
MISSING=$(echo "$OUTPUT" | grep ':MISSING' || true)

if [[ -n "$FAILS" ]]; then
  echo "FAIL — zsh errors:"
  echo "$FAILS"
  exit 1
fi

[[ -n "$MISSING" ]] && echo "WARN — some tools missing: $MISSING"

echo "PASS: zsh configuration sourced cleanly on macOS ($(uname -m) / $(sw_vers -productVersion))"
