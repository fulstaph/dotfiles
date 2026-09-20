#!/usr/bin/env zsh
# install.zsh — symlink dotfiles into place
# Usage: zsh install.zsh [--dry-run]

set -euo pipefail

DRY=${1:-}
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ "$DRY" == "--dry-run" ]]; then
    echo "[dry] $dst -> $src"
    return
  fi
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "  ok  $dst"
    return
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local bak="${dst}.bak.$(date +%s)"
    echo " bak  $dst -> $bak"
    mv "$dst" "$bak"
  fi
  ln -sf "$src" "$dst"
  echo "link  $dst"
}

echo "==> zsh"
link "$DOTFILES/zsh/.zshrc"   "$HOME/.zshrc"
link "$DOTFILES/zsh/.zshenv"  "$HOME/.zshenv"
link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"

echo "==> starship"
link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

echo "==> ghostty"
link "$DOTFILES/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"

echo
echo "Done. Open a new shell or run: exec zsh"
