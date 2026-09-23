#!/usr/bin/env bash
# scripts/test-zshrc.sh
# Verifies zshrc sources cleanly on Linux.
# In CI / containers: install distro packages only; optional tools may be absent.
# On real machines: dependencies are managed by scripts/install.zsh.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
ARCH=$(uname -m)

# ── Install dependencies ───────────────────────────────────────────────────
install_deps() {
  if command -v apt-get &>/dev/null; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq \
      zsh curl git fzf bat \
      zsh-autosuggestions zsh-syntax-highlighting \
      fd-find >/dev/null 2>&1
    command -v fd &>/dev/null || ln -sf "$(command -v fdfind)" /usr/local/bin/fd

  elif command -v dnf &>/dev/null; then
    dnf install -y -q zsh curl git fzf bat fd-find \
      zsh-autosuggestions zsh-syntax-highlighting >/dev/null 2>&1

  elif command -v pacman &>/dev/null; then
    pacman -Sy --noconfirm --quiet \
      zsh curl git fzf bat fd \
      zsh-autosuggestions zsh-syntax-highlighting >/dev/null 2>&1
  fi

}

echo "==> Installing dependencies..."
install_deps

echo ""
echo "=== tool versions ==="
printf "  zsh:      %s\n" "$(zsh --version)"
printf "  eza:      %s\n" "$(eza --version 2>/dev/null | head -1 || echo MISSING)"
printf "  zoxide:   %s\n" "$(zoxide --version 2>/dev/null || echo MISSING)"
printf "  starship: %s\n" "$(starship --version 2>/dev/null | head -1 || echo MISSING)"
printf "  fzf:      %s\n" "$(fzf --version 2>/dev/null || echo MISSING)"
echo ""

# Isolate test in a temp home so we don't pollute the real one
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

[[ -n "$MISSING" ]] && echo "WARN — some tools missing (non-fatal): $MISSING"

PRETTY_NAME=$(grep -m1 '^PRETTY_NAME' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Linux")
echo "PASS: zsh configuration sourced cleanly on Linux (${ARCH} / ${PRETTY_NAME})"
