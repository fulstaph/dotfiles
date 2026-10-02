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
| [`zellij/`](zellij/README.md) | Zellij multiplexer ([tmux keybinds](zellij/README.md)) | `~/.config/zellij/` |
| `nvim/` | Neovim (LazyVim) | `~/.config/nvim/` |
| `git/` | Git config | `~/.gitconfig` |
| `zed/` | Zed editor | `~/.config/zed/settings.json` |
| `gh/` | GitHub CLI | `~/.config/gh/config.yml` |

## Python notebooks in Neovim

The Neovim config opens `.ipynb` files as Jupytext Python percent-cell buffers.
Save with `:write` to update the notebook. The full `setup.sh` bootstrap installs
Jupytext and creates a Neovim Python environment with Molten's required Python
packages plus a `Python (Neovim)` Jupyter kernel.

For a symlinks-only install, ensure `uv` is available (for example, `brew install uv`),
then create that environment manually:

```sh
uv tool install --python 3.12 jupytext
uv venv --python 3.12 ~/.local/share/nvim/venv
uv pip install --python ~/.local/share/nvim/venv/bin/python3 \
  pynvim jupyter_client ipykernel
~/.local/share/nvim/venv/bin/python3 -m ipykernel install --user \
  --name neovim-python --display-name "Python (Neovim)"
```

Open or create a notebook with `nvim file.ipynb` or `:NewPythonNotebook file`.
Use `<leader>ji` to select a kernel, `<leader>jr` to run the code cell under
the cursor, and `<leader>jc` to run it and advance. `<leader>j[` and
`<leader>j]` move between cells; `<leader>jv` runs a visual selection.
Molten outputs are not written into the notebook automatically; use
`<leader>jE` to export them. Image rendering is currently disabled.

## Taskfiles in Neovim

[taskfile.nvim](https://github.com/fulstaph/taskfile.nvim) provides task picking,
terminal execution, and inline task markers. Install the [Task CLI](https://taskfile.dev/installation/)
and use `<leader>Tr` to pick a task, `<leader>Ta` to include undocumented tasks,
`<leader>Td` for a dry run, `<leader>Tl` to rerun the last task, `<leader>Te` to
edit the Taskfile, and `<leader>Tc` to run the task under the cursor. Save the
Taskfile before running from the cursor.

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

## Agent Lens beta

Neovim pins `fulstaph/agent-lens.nvim` to `v0.1.0-beta.1` with read tracking,
inline activity, Follow Agent, and animated live previews enabled. `setup.sh`
installs the matching OMP bridge when `omp` is available, adding Bun 1.4.2
under `~/.local` if its package installer needs it. Restart Neovim and
OMP after installation. Use `<leader>al` for the timeline, `<leader>af` to
toggle following, `<leader>ar` to resume, `<leader>as` for status, and
`<leader>ap` to preview a hunk.

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
