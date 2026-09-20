#!/usr/bin/env bash
# scripts/test-zshrc.sh
# Verifies zshrc sources cleanly on Linux.
# In CI / containers: installs deps via apt + upstream curl (fast, no brew).
# On real machines: deps should already be managed by install.zsh (brew).
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

  # eza — prebuilt binary, arch-aware
  if ! command -v eza &>/dev/null; then
    case "$ARCH" in
      x86_64)  EZA_TRIPLE="x86_64-unknown-linux-gnu" ;;
      aarch64) EZA_TRIPLE="aarch64-unknown-linux-gnu" ;;
      *)       EZA_TRIPLE="" ;;
    esac
    if [[ -n "$EZA_TRIPLE" ]]; then
      EZA_VER=$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
      curl -fsSL \
        "https://github.com/eza-community/eza/releases/download/${EZA_VER}/eza_${EZA_TRIPLE}.tar.gz" \
        | tar -xz -C /usr/local/bin 2>/dev/null && chmod +x /usr/local/bin/eza
    fi
  fi

  # zoxide — install script, puts binary in ~/.local/bin
  if ! command -v zoxide &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
      | bash >/dev/null 2>&1
    # Make available system-wide for the test
    cp "$HOME/.local/bin/zoxide" /usr/local/bin/zoxide 2>/dev/null || true
  fi

  # starship
  if ! command -v starship &>/dev/null; then
    curl -fsSL https://starship.rs/install.sh \
      | sh -s -- --yes --bin-dir /usr/local/bin >/dev/null 2>&1
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
mkdir -p "$TESTHOME/.config"
cp "$DOTFILES/starship/starship.toml" "$TESTHOME/.config/starship.toml"

echo "=== sourcing zshrc ==="
OUTPUT=$(TERM=xterm-256color HOME="$TESTHOME" zsh --no-rcs -c '
  source "$HOME/.zshrc"
  echo "OK:ALIASES:$(alias | wc -l | tr -d " ")"
  echo "OK:CD_TYPE:$(type cd | head -1)"
  echo "OK:OS_VAR:$OS"
  echo "OK:BREW:${BREW:-none}"
  echo "OK:STARSHIP:$(starship --version | head -1)"
  echo "OK:EZA:$(eza --version 2>/dev/null | head -1 || echo MISSING)"
  echo "OK:ZOXIDE:$(zoxide --version 2>/dev/null || echo MISSING)"
  echo "OK:FZF:$(fzf --version 2>/dev/null || echo MISSING)"
' 2>&1 | grep -v 'not interactive\|compinit\|compdef\|can.t change option\|dumb.*terminal')

echo "$OUTPUT"
echo ""

FAILS=$(echo "$OUTPUT" | grep -E '^zsh[^:]*:[0-9]+: ' | grep -v 'compinit\|compdef' || true)
MISSING=$(echo "$OUTPUT" | grep ':MISSING' || true)

if [[ -n "$FAILS" ]]; then
  echo "FAIL — zsh errors:"
  echo "$FAILS"
  exit 1
fi

[[ -n "$MISSING" ]] && echo "WARN — some tools missing (non-fatal): $MISSING"

PRETTY_NAME=$(grep -m1 '^PRETTY_NAME' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Linux")
echo "PASS: zshrc sourced cleanly on Linux (${ARCH} / ${PRETTY_NAME})"
