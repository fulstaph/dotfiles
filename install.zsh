#!/usr/bin/env zsh
# install.zsh — bootstrap Homebrew, install tools, symlink dotfiles
# Usage: zsh install.zsh [--dry-run]

set -euo pipefail

DRY=${1:-}
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# ── Platform ──────────────────────────────────────────────────────────────
case "$OSTYPE" in
  darwin*) OS=mac ;;
  linux*)  OS=linux ;;
  *)       OS=unknown ;;
esac

# ── Homebrew ──────────────────────────────────────────────────────────────
_find_brew() {
  for p in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew \
    "$HOME/.linuxbrew/bin/brew"; do
    [[ -x "$p" ]] && echo "$p" && return
  done
}

BREW_BIN=$(_find_brew)

if [[ -z "$BREW_BIN" ]]; then
  if [[ "$DRY" == "--dry-run" ]]; then
    echo "[dry] would install Homebrew"
  else
    echo "==> Homebrew not found — installing..."
    NONINTERACTIVE=1 bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    BREW_BIN=$(_find_brew)
  fi
fi

if [[ -n "$BREW_BIN" && "$DRY" != "--dry-run" ]]; then
  eval "$($BREW_BIN shellenv)"
  echo "==> Installing packages via Homebrew..."
  brew install --quiet \
    eza zoxide starship fzf bat fd \
    zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
    2>/dev/null || true
  # macOS: nvm lives in brew; Linux: install script puts it in ~/.nvm
  if [[ $OS == mac ]]; then
    brew install --quiet nvm 2>/dev/null || true
  fi
elif [[ "$DRY" == "--dry-run" ]]; then
  echo "[dry] would brew install eza zoxide starship fzf bat fd ..."
fi


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

echo "==> zellij"
link "$DOTFILES/zellij/config.kdl"          "$HOME/.config/zellij/config.kdl"
link "$DOTFILES/zellij/layouts/default.kdl" "$HOME/.config/zellij/layouts/default.kdl"

echo "==> nvim"
link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo
echo "Done. Open a new shell or run: exec zsh"
