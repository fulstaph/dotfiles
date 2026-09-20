#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
  zsh curl git fzf bat \
  zsh-autosuggestions zsh-syntax-highlighting \
  fd-find >/dev/null 2>&1

ln -sf "$(which fdfind)" /usr/local/bin/fd

# eza — arch-aware
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  EZA_TRIPLE="x86_64-unknown-linux-gnu" ;;
  aarch64) EZA_TRIPLE="aarch64-unknown-linux-gnu" ;;
  *)       echo "WARNING: no eza binary for $ARCH" ; EZA_TRIPLE="" ;;
esac
if [[ -n "$EZA_TRIPLE" ]]; then
  EZA_VER=$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
  curl -fsSL "https://github.com/eza-community/eza/releases/download/${EZA_VER}/eza_${EZA_TRIPLE}.tar.gz" \
    | tar -xz -C /usr/local/bin 2>/dev/null && chmod +x /usr/local/bin/eza
fi

# zoxide
curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
  | bash >/dev/null 2>&1
cp /root/.local/bin/zoxide /usr/local/bin/zoxide

# starship
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin >/dev/null 2>&1

echo "=== tool versions ==="
printf "  zsh:      %s\n" "$(zsh --version)"
printf "  eza:      %s\n" "$(eza --version 2>/dev/null | head -1 || echo MISSING)"
printf "  zoxide:   %s\n" "$(zoxide --version)"
printf "  starship: %s\n" "$(starship --version | head -1)"
printf "  fzf:      %s\n" "$(fzf --version)"
echo ""

cp /dotfiles/zsh/.zshrc /root/.zshrc
mkdir -p /root/.config
cp /dotfiles/starship/starship.toml /root/.config/starship.toml

echo "=== sourcing zshrc ==="
OUTPUT=$(TERM=xterm-256color HOME=/root zsh --no-rcs -c '
  source /root/.zshrc
  echo "ALIASES:$(alias | wc -l | tr -d " ")"
  echo "CD_TYPE:$(type cd | head -1)"
  echo "STARSHIP:$(starship --version | head -1)"
  echo "EZA:$(eza --version 2>/dev/null | head -1 || echo MISSING)"
  echo "ZOXIDE:$(zoxide --version)"
  echo "FZF:$(fzf --version)"
  echo "OS_VAR:$OS"
' 2>&1 | grep -v 'not interactive\|compinit\|compdef\|can.t change option\|dumb.*terminal')

echo "$OUTPUT"
echo ""

FAILS=$(echo "$OUTPUT" | grep -E '^zsh[^:]*:(.*:)? (command not found|no such file|unbound variable|unmatched|parse error)' || true)
if [[ -n "$FAILS" ]]; then
  echo "FAIL:"
  echo "$FAILS"
  exit 1
else
  echo "PASS: zshrc sourced cleanly on Linux ($(uname -m))"
fi
