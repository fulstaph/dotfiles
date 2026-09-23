#!/usr/bin/env bash
# setup.sh — bootstrap a fresh machine with dotfiles + all dependencies
#
# Run after cloning:
#   bash ~/dotfiles/setup.sh
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────
GRN='\033[0;32m'; YLW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { printf "\n%b==>%b %s\n" "$GRN" "$NC" "$1"; }
warn() { printf "%bwarn%b %s\n"  "$YLW" "$NC" "$1"; }
die()  { printf "%berror%b %s\n" "$RED" "$NC" "$1"; exit 1; }

HOMEBREW_INSTALL_COMMIT="b41c8e7b3588e2899974119faf3b2a897428648d"
HOMEBREW_INSTALL_SHA256="71d25d14c32edd7adeaf4413ba671b28474ea08e4f6662cb1a73e85ff0eba368"

has_command() {
  command -v "$1" >/dev/null 2>&1
}

install_system_packages() {
  local packages=("$@")

  has_command sudo || die "Installing bootstrap dependencies requires sudo"
  sudo -v || die "Installing bootstrap dependencies requires an interactive sudo-capable user"

  case "$OS" in
    linux)
      if has_command apt-get; then
        sudo apt-get update
        sudo env DEBIAN_FRONTEND=noninteractive \
          apt-get install --yes --no-install-recommends "${packages[@]}"
      elif has_command dnf; then
        sudo dnf install --assumeyes "${packages[@]}"
      elif has_command pacman; then
        sudo pacman -Sy --noconfirm "${packages[@]}"
      else
        die "Install ${packages[*]} with your package manager, then rerun setup.sh"
      fi
      ;;
    mac)
      xcode-select --install >/dev/null 2>&1 || true
      die "Install the macOS Command Line Tools, then rerun setup.sh"
      ;;
  esac
}

ensure_bootstrap_tools() {
  local packages=()

  has_command git || packages+=("git")
  has_command curl || packages+=("curl")
  ((${#packages[@]} == 0)) && return

  step "Bootstrap dependencies"
  install_system_packages "${packages[@]}"
  for tool in "${packages[@]}"; do
    has_command "$tool" || die "Failed to install required bootstrap tool: $tool"
  done
}

verify_sha256() {
  local expected="$1" file="$2" actual

  if has_command sha256sum; then
    actual=$(sha256sum "$file")
  else
    actual=$(shasum -a 256 "$file")
  fi
  [[ "${actual%% *}" == "$expected" ]]
}

install_homebrew() {
  local installer

  installer=$(mktemp) || die "Unable to create a temporary Homebrew installer"
  if ! curl --fail --silent --show-error --location \
    --output "$installer" \
    "https://raw.githubusercontent.com/Homebrew/install/$HOMEBREW_INSTALL_COMMIT/install.sh"; then
    rm -f "$installer"
    die "Failed to download the pinned Homebrew installer"
  fi
  if ! verify_sha256 "$HOMEBREW_INSTALL_SHA256" "$installer"; then
    rm -f "$installer"
    die "Homebrew installer checksum mismatch"
  fi

  if [[ "$PLATFORM" == wsl ]]; then
    if ! bash "$installer"; then
      rm -f "$installer"
      die "Homebrew installation failed"
    fi
  elif ! NONINTERACTIVE=1 bash "$installer"; then
    rm -f "$installer"
    die "Homebrew installation failed"
  fi
  rm -f "$installer"
}


# ── Platform ──────────────────────────────────────────────────────────────
is_wsl() {
  local version_file="${1:-/proc/version}"
  [[ -r "$version_file" ]] && grep -qi 'microsoft' "$version_file" 2>/dev/null
}

detect_platform() {
  local version_file="${1:-/proc/version}"

  case "$OSTYPE" in
    darwin*) OS=mac ;;
    linux*)  OS=linux ;;
    *) die "Unsupported OS: $OSTYPE" ;;
  esac

  PLATFORM="$OS"
  if [[ "$OS" == linux ]] && is_wsl "$version_file"; then
    PLATFORM=wsl
  fi
}
setup_wsl_prerequisites() {
  command -v apt-get >/dev/null || \
    die "WSL setup requires an Ubuntu or Debian distribution with apt-get"
  command -v sudo >/dev/null || \
    die "WSL setup requires a sudo-capable user"

  step "WSL prerequisites"
  if ! sudo -v; then
    die "WSL setup requires an interactive sudo-capable user"
  fi
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes --no-install-recommends \
      build-essential procps curl file git
}

detect_platform /proc/version

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  return 0
fi

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
REPO="https://github.com/fulstaph/dotfiles"

if [[ "$PLATFORM" == wsl && "$DOTFILES" == /mnt/* ]]; then
  warn "WSL performs best from its Linux filesystem; prefer ~/dotfiles over $DOTFILES"
fi


if [[ "$PLATFORM" == wsl ]]; then
  setup_wsl_prerequisites
fi
ensure_bootstrap_tools


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
  install_homebrew
  BREW_BIN=$(_find_brew) || die "Homebrew install succeeded but brew not found"
fi

eval "$("$BREW_BIN" shellenv)"


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

"$BREW_BIN" install --quiet "${PACKAGES[@]}"

# ── 4. Symlink dotfiles ───────────────────────────────────────────────────
step "Symlinking dotfiles"
zsh "$DOTFILES/scripts/install.zsh"

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
    if ! git -C "$OMP_SRC" pull --ff-only; then
      warn "failed to update Oh My Pi config; keeping the existing checkout"
    fi
  else
    if ! git clone --depth=1 https://github.com/fulstaph/omp-config.git "$OMP_SRC"; then
      warn "failed to clone Oh My Pi config; continuing without a config sync"
    fi
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
    if ! git -C "$PI_SRC" pull --ff-only; then
      warn "failed to update Pi config; keeping the existing checkout"
    fi
  else
    if ! git clone --depth=1 https://github.com/fulstaph/pi-agent-config.git "$PI_SRC"; then
      warn "failed to clone Pi config; continuing without a config sync"
    fi
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
