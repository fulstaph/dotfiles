#!/usr/bin/env zsh
# install.zsh — symlink dotfiles into place
# Usage: zsh install.zsh [--dry-run] [--packages]

set -euo pipefail

DRY=false
INSTALL_PACKAGES=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=true ;;
    --packages|--with-brew) INSTALL_PACKAGES=true ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# ── Optional package bootstrap (--packages) ────────────────────────────────
if [[ "$INSTALL_PACKAGES" == true ]]; then
  case "$OSTYPE" in
    darwin*) OS=mac ;;
    linux*)  OS=linux ;;
    *)       OS=unknown ;;
  esac

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
    if [[ "$DRY" == true ]]; then
      echo "[dry] would install Homebrew"
    else
      echo "==> Homebrew not found — installing..."
      NONINTERACTIVE=1 bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      BREW_BIN=$(_find_brew)
    fi
  fi

  if [[ -n "$BREW_BIN" && "$DRY" != true ]]; then
    eval "$($BREW_BIN shellenv)"
    echo "==> Installing packages via Homebrew..."
    brew install --quiet \
      eza zoxide starship fzf bat fd \
      zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
      2>/dev/null || true
    if [[ $OS == mac ]]; then
      brew install --quiet nvm 2>/dev/null || true
    fi
  elif [[ "$DRY" == true ]]; then
    echo "[dry] would brew install eza zoxide starship fzf bat fd ..."
  fi
fi

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ "$DRY" == true ]]; then
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
