# dotfiles

Personal shell and editor config. **Single source of truth** — no separate per-tool repos.

## Fresh machine setup

One command — installs Homebrew if missing, installs all tools, symlinks configs, sets zsh as default shell:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fulstaph/dotfiles/main/setup.sh)"
```

Or if already cloned:

```sh
bash ~/dotfiles/setup.sh
```

## Contents

| Directory | Tool | Symlinked to |
|---|---|---|
| `zsh/` | Zsh | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `starship/` | Starship prompt | `~/.config/starship.toml` |
| `ghostty/` | Ghostty terminal | `~/.config/ghostty/config.ghostty` |
| `zellij/` | Zellij multiplexer | `~/.config/zellij/` |
| `nvim/` | Neovim (LazyVim) | `~/.config/nvim/` |

## Symlinks only (existing machine)

```sh
zsh install.zsh           # symlink all configs
zsh install.zsh --dry-run # preview without changing anything
```

Existing files are backed up to `<file>.bak.<timestamp>` before symlinking.

## Editing

Edit files in `~/dotfiles/` — symlinks mean changes are live immediately:

```sh
cd ~/dotfiles
git add -A && git commit -m "..." && git push
```

## CI

| Job | What it tests |
|---|---|
| `zshrc — ubuntu:24.04` | Sources cleanly, all tools resolve |
| `zshrc — ubuntu:22.04` | Same on older LTS |
| `zshrc — macos-latest` | Sources cleanly via Homebrew |
| `shellcheck` | Bash scripts are clean |

## Local Linux test (macOS dev)

Requires podman or docker:

```sh
bash test-linux.sh
```
