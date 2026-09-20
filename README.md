# dotfiles

Personal shell and editor config. **Single source of truth** — no separate per-tool repos.

## Contents

| Directory | Tool | Symlinked to |
|---|---|---|
| `zsh/` | Zsh | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `starship/` | Starship prompt | `~/.config/starship.toml` |
| `ghostty/` | Ghostty terminal | `~/.config/ghostty/config.ghostty` |
| `zellij/` | Zellij multiplexer | `~/.config/zellij/` |
| `nvim/` | Neovim (LazyVim) | `~/.config/nvim/` |

## Install

```zsh
git clone https://github.com/fulstaph/dotfiles ~/dotfiles
cd ~/dotfiles
zsh install.zsh
```

Preview without touching anything:

```zsh
zsh install.zsh --dry-run
```

Existing files are moved to `<file>.bak.<timestamp>` before symlinking.

## Dependencies

### macOS (Homebrew)

```zsh
brew install eza zoxide starship fzf bat fd \
  zsh-autosuggestions zsh-syntax-highlighting zsh-completions
```

### Linux (apt)

```sh
apt install zsh fzf bat fd-find zsh-autosuggestions zsh-syntax-highlighting
# then install from upstream (no apt package):
curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
curl -fsSL https://starship.rs/install.sh | sh
# eza: grab release binary from https://github.com/eza-community/eza/releases
```

## Testing on Linux

Requires podman or docker:

```zsh
zsh test-linux.sh   # runs Ubuntu 24.04 container, installs deps, sources config
```

## Editing

Edit files in `~/dotfiles/` — symlinks mean changes are live immediately.

```zsh
cd ~/dotfiles
git add -A && git commit -m "..." && git push
```
