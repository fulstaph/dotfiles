#!/usr/bin/env bash
# setup.sh — bootstrap a fresh machine with dotfiles + all dependencies
#
# One-liner install:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/fulstaph/dotfiles/main/setup.sh)"
#
# Or if already cloned:
#   bash ~/dotfiles/setup.sh
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────
GRN='\033[0;32m'; YLW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { printf "\n%b==>%b %s\n" "$GRN" "$NC" "$1"; }
warn() { printf "%bwarn%b %s\n"  "$YLW" "$NC" "$1"; }
die()  { printf "%berror%b %s\n" "$RED" "$NC" "$1"; exit 1; }

# ── Platform ──────────────────────────────────────────────────────────────
case "$OSTYPE" in
  darwin*) OS=mac ;;
  linux*)  OS=linux ;;
  *) die "Unsupported OS: $OSTYPE" ;;
esac

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
REPO="https://github.com/fulstaph/dotfiles"

# ── 1. Clone or update dotfiles ───────────────────────────────────────────
step "Dotfiles ($DOTFILES)"
if [[ -d "$DOTFILES/.git" ]]; then
  echo "  found — pulling latest..."
  git -C "$DOTFILES" pull --ff-only
else
  echo "  cloning $REPO..."
  git clone "$REPO" "$DOTFILES"
fi

# ── 2. Homebrew ───────────────────────────────────────────────────────────
step "Homebrew"
_find_brew() {
  for p in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew \
    "$HOME/.linuxbrew/bin/brew"; do
    [[ -x "$p" ]] && echo "$p" && return 0
  done
  return 1
}

if BREW_BIN=$(_find_brew); then
  echo "  found at $BREW_BIN"
else
  echo "  not found — installing..."
  NONINTERACTIVE=1 bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_BIN=$(_find_brew) || die "Homebrew install succeeded but brew not found"
fi

eval "$($BREW_BIN shellenv)"

# ── 3. Core packages ──────────────────────────────────────────────────────
step "Packages"
PACKAGES=(
  # shell
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  # prompt + nav
  starship
  zoxide
  fzf
  # modern replacements
  eza
  bat
  fd
  ripgrep
  # editor
  neovim
  # multiplexer
  zellij
  # essentials
  git
  gh
  curl
)

if [[ $OS == mac ]]; then
  PACKAGES+=(nvm)
fi

brew install --quiet "${PACKAGES[@]}" 2>/dev/null || true

# ── 4. Symlink dotfiles ───────────────────────────────────────────────────
step "Symlinking dotfiles"
zsh "$DOTFILES/install.zsh"

# ── 5. Set default shell to zsh ───────────────────────────────────────────
step "Default shell"
if [[ "$SHELL" == *"zsh"* ]]; then
  echo "  already zsh ($SHELL)"
else
  ZSH_PATH=$(command -v zsh || echo "/bin/zsh")
  if ! grep -qF "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "  adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  echo "  changing default shell to $ZSH_PATH..."
  chsh -s "$ZSH_PATH"
  echo "  re-login or run: exec zsh"
fi

# ── 6. Agent configs (Oh My Pi & Pi) ──────────────────────────────────────
step "Agent configs (Oh My Pi & Pi)"

# Oh My Pi (~/.omp/agent)
OMP_DIR="$HOME/.omp/agent"
OMP_SRC="${OMP_CONFIG_DIR:-$HOME/.config/omp-config}"
if [[ -d "$OMP_DIR" ]] || command -v omp &>/dev/null; then
  echo "  syncing Oh My Pi configs (fulstaph/omp-config)..."
  mkdir -p "$OMP_DIR"
  if [[ -d "$OMP_SRC/.git" ]]; then
    git -C "$OMP_SRC" pull --ff-only 2>/dev/null || true
  else
    git clone --depth=1 https://github.com/fulstaph/omp-config.git "$OMP_SRC" 2>/dev/null || true
  fi
  if [[ -d "$OMP_SRC" ]]; then
    for f in config.yml models.yml plugins.json; do
      if [[ -f "$OMP_SRC/$f" && ! -f "$OMP_DIR/$f" ]]; then
        cp "$OMP_SRC/$f" "$OMP_DIR/$f"
        echo "    seeded $f"
      fi
    done
  fi
else
  echo "  omp not detected — skipping (clone fulstaph/omp-config if installing later)"
fi

# Pi (~/.pi/agent)
PI_DIR="$HOME/.pi/agent"
PI_SRC="${PI_CONFIG_DIR:-$HOME/.config/pi-agent-config}"
if [[ -d "$PI_DIR" ]] || command -v pi &>/dev/null; then
  echo "  syncing Pi configs (fulstaph/pi-agent-config)..."
  mkdir -p "$PI_DIR"
  if [[ -d "$PI_SRC/.git" ]]; then
    git -C "$PI_SRC" pull --ff-only 2>/dev/null || true
  else
    git clone --depth=1 https://github.com/fulstaph/pi-agent-config.git "$PI_SRC" 2>/dev/null || true
  fi
  if [[ -d "$PI_SRC" ]]; then
    for item in AGENTS.md CLAUDE.md keybindings.json mcp.json settings.json agents prompts skills; do
      if [[ -e "$PI_SRC/$item" && ! -e "$PI_DIR/$item" ]]; then
        ln -sf "$PI_SRC/$item" "$PI_DIR/$item"
        echo "    linked $item"
      fi
    done
  fi
else
  echo "  pi not detected — skipping (clone fulstaph/pi-agent-config if installing later)"
fi

# ── Done ──────────────────────────────────────────────────────────────────
printf "\n%bDone!%b Start a new shell: exec zsh\n" "$GRN" "$NC"
