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
| `git/` | Git config | `~/.gitconfig` |
| `zed/` | Zed editor | `~/.config/zed/settings.json` |
| `gh/` | GitHub CLI | `~/.config/gh/config.yml` |
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

## Git Identity (Work vs Personal Isolation)

`git/.gitconfig` provides global sane defaults (`nvim` editor, `pull.rebase`, `zdiff3` conflicts, `autoSetupRemote`), but intentionally **omits any author name or email**.

Instead, it includes `~/.gitconfig.local`:

```ini
# ~/.gitconfig.local (never committed)
[user]
    name = Your Name
    email = your.work.or.personal.email@example.com
```

`install.zsh` auto-creates a template if none exists. Your work credentials stay purely on your machine.

## Agent Configs (Oh My Pi & Pi)

`setup.sh` detects if [Oh My Pi](https://github.com/fulstaph/omp-config) or [Pi](https://github.com/fulstaph/pi-agent-config) are installed and automatically syncs their non-credential configurations from your dedicated agent repos (`fulstaph/omp-config` and `fulstaph/pi-agent-config`).

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
