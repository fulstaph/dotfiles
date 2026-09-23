# dotfiles

Personal shell and editor config. **Single source of truth** — no separate per-tool repos.

## Fresh machine setup

Install Git once, clone the repository, then run the reviewed local bootstrap:

On macOS, finish the Command Line Tools prompt before continuing.

```sh
# macOS
xcode-select --install

# Ubuntu / WSL
sudo apt-get update && sudo apt-get install --yes git curl

git clone https://github.com/fulstaph/dotfiles.git ~/dotfiles
bash ~/dotfiles/setup.sh
```

### Windows (WSL 2)

Install a WSL 2 distribution once from an elevated PowerShell:

```powershell
wsl --install -d Ubuntu
```

Open Ubuntu, create its non-root sudo user, clone the repository, then run
`setup.sh` from the WSL terminal. It detects WSL, installs Homebrew's
Ubuntu/Debian prerequisites before Homebrew, and leaves the initial Homebrew
install interactive for its sudo confirmation. Keep the repository in the Linux
filesystem (`~/dotfiles`, the default), not under `/mnt/c`. WSL 1 is not a
supported target.

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
zsh scripts/install.zsh           # symlink all configs
zsh scripts/install.zsh --dry-run # preview without changing anything
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

`scripts/install.zsh` auto-creates a template if none exists. Your work credentials stay purely on your machine.

## Agent Configs (Oh My Pi & Pi)

`setup.sh` detects if [Oh My Pi](https://github.com/fulstaph/omp-config) or [Pi](https://github.com/fulstaph/pi-agent-config) are installed and automatically syncs their non-credential configurations from your dedicated agent repos (`fulstaph/omp-config` and `fulstaph/pi-agent-config`).

## CI

| Job | What it tests |
|---|---|
| `zsh configuration — ubuntu:24.04` | Sources `.zprofile` and `.zshrc`, all tools resolve |
| `zsh configuration — ubuntu:22.04` | Same on older LTS |
| `zsh configuration — macos-latest` | Sources `.zprofile` and `.zshrc` via Homebrew |
| `setup platform detection` | Selects macOS, Linux, and WSL paths |
| `shellcheck` | Bash scripts are clean |
| `nvim configuration` | JSON, Lua syntax, and Stylua formatting |
| `nvim smoke test` | Installs the pinned Neovim release and syncs the locked plugin set |


## Local Linux test (macOS dev)

Requires podman or docker:

```sh
bash scripts/test-linux-container.sh
```
