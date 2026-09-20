# dotfiles

Personal shell configuration managed as symlinks.

## Contents

| Path in repo | Symlinked to |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zshenv` | `~/.zshenv` |
| `zsh/.zprofile` | `~/.zprofile` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` |

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

## Dependencies (macOS / Homebrew)

```zsh
brew install eza zoxide starship fzf bat zsh-autosuggestions zsh-syntax-highlighting zsh-completions
```
