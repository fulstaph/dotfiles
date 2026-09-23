#!/usr/bin/env zsh
# scripts/install.zsh — symlink dotfiles into place
# Usage: zsh scripts/install.zsh [--dry-run] [--packages]

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

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

# ── Optional package bootstrap (--packages) ────────────────────────────────
HOMEBREW_INSTALL_COMMIT="b41c8e7b3588e2899974119faf3b2a897428648d"
HOMEBREW_INSTALL_SHA256="71d25d14c32edd7adeaf4413ba671b28474ea08e4f6662cb1a73e85ff0eba368"
: "${BREW_CANDIDATES:=/opt/homebrew/bin/brew:/usr/local/bin/brew:/home/linuxbrew/.linuxbrew/bin/brew:$HOME/.linuxbrew/bin/brew}"

_find_brew() {
  local p
  for p in "${(@s/:/)BREW_CANDIDATES}"; do
    [[ -x "$p" ]] && print -r -- "$p" && return 0
  done
  return 1
}

verify_sha256() {
  local expected="$1" file="$2" actual

  if (( $+commands[sha256sum] )); then
    actual=$(sha256sum "$file")
  else
    actual=$(shasum -a 256 "$file")
  fi
  [[ "${actual%% *}" == "$expected" ]]
}

install_homebrew() {
  local installer

  if (( ! $+commands[curl] )); then
    print -u2 -- "error: curl is required to install Homebrew"
    return 1
  fi

  installer=$(mktemp) || return 1
  if ! curl --fail --silent --show-error --location \
    --output "$installer" \
    "https://raw.githubusercontent.com/Homebrew/install/$HOMEBREW_INSTALL_COMMIT/install.sh"; then
    print -u2 -- "error: failed to download the pinned Homebrew installer"
    rm -f "$installer"
    return 1
  fi
  if ! verify_sha256 "$HOMEBREW_INSTALL_SHA256" "$installer"; then
    print -u2 -- "error: Homebrew installer checksum mismatch"
    rm -f "$installer"
    return 1
  fi
  if ! NONINTERACTIVE=1 bash "$installer"; then
    rm -f "$installer"
    return 1
  fi
  rm -f "$installer"
}

if [[ "$INSTALL_PACKAGES" == true ]]; then
  case "$OSTYPE" in
    darwin*) OS=mac ;;
    linux*)  OS=linux ;;
    *)       OS=unknown ;;
  esac

  if ! BREW_BIN=$(_find_brew); then
    BREW_BIN=""
  fi
  if [[ -z "$BREW_BIN" ]]; then
    if [[ "$DRY" == true ]]; then
      print -- "[dry] would install Homebrew"
    else
      print -- "==> Homebrew not found — installing..."
      install_homebrew || exit 1
      BREW_BIN=$(_find_brew) || {
        print -u2 -- "error: Homebrew install succeeded but brew was not found"
        exit 1
      }
    fi
  fi

  if [[ -n "$BREW_BIN" && "$DRY" != true ]]; then
    eval "$("$BREW_BIN" shellenv)"
    print -- "==> Installing packages via Homebrew..."
    brew install --quiet \
      eza zoxide starship fzf bat fd \
      zsh-autosuggestions zsh-syntax-highlighting zsh-completions
    if [[ "$OS" == mac ]]; then
      brew install --quiet nvm
    fi
  elif [[ "$DRY" == true ]]; then
    print -- "[dry] would brew install eza zoxide starship fzf bat fd ..."
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
link "$DOTFILES/zellij/layouts/omp.kdl"     "$HOME/.config/zellij/layouts/omp.kdl"
link "$DOTFILES/zellij/README.md"           "$HOME/.config/zellij/README.md"
link "$DOTFILES/zellij/plugins/zellij_forgot.wasm" "$HOME/.config/zellij/plugins/zellij_forgot.wasm"
link "$DOTFILES/zellij/plugins/zjstatus.wasm"      "$HOME/.config/zellij/plugins/zjstatus.wasm"
link "$DOTFILES/zellij/plugins/SHA256SUMS"         "$HOME/.config/zellij/plugins/SHA256SUMS"

echo "==> nvim"
link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "==> git"
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
if [[ ! -f "$HOME/.gitconfig.local" && "$DRY" != true ]]; then
  echo "  creating ~/.gitconfig.local template..."
  cat > "$HOME/.gitconfig.local" <<'EOF'
# Local machine-specific Git identity — never committed to public dotfiles.
[user]
    name = Your Name
    email = your.email@example.com
EOF
elif [[ "$DRY" == true && ! -f "$HOME/.gitconfig.local" ]]; then
  echo "[dry] would create ~/.gitconfig.local template"
fi

echo "==> zed"
link "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"

echo "==> gh"
link "$DOTFILES/gh/config.yml" "$HOME/.config/gh/config.yml"

echo
echo "Done. Open a new shell or run: exec zsh"
