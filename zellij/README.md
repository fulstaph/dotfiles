# Zellij Configuration (tmux Emulation)

Personal [Zellij](https://zellij.dev/) configuration tuned for Neovim, Ghostty, and Oh My Pi.

## Philosophy

- **`Locked` by Default**: Keystrokes pass through untouched to Neovim and shell TUIs.
- **`Ctrl-a` Prefix**: Press `Ctrl-a` to enter `TMUX` prefix mode (indicated in the status bar).
- **Auto-Return**: Single-stroke commands execute and immediately switch back to `Locked` mode so you can continue typing in your application without an extra keypress.
- **Direct Alt Shortcuts**: `Alt 1`–`9` (tab jumping) and `Alt h/j/k/l` (pane focus) work instantly in one stroke without pressing the prefix.

---

## Keybindings Reference

Prefix: **`Ctrl-a`**

### Tab Management (Windows)

| Shortcut | Action | Description |
|---|---|---|
| `Ctrl-a` `1`..`9` | `GoToTab 1..9` | Jump directly to tab 1–9 and lock |
| `Alt` `1`..`9` | `GoToTab 1..9` | Direct 1-stroke jump to tab 1–9 (no prefix) |
| `Ctrl-a` `c` | `NewTab` | Create a new tab |
| `Ctrl-a` `n` | `GoToNextTab` | Switch to next tab |
| `Ctrl-a` `p` | `GoToPreviousTab` | Switch to previous tab |
| `Ctrl-a` `Ctrl-a` / `Tab` | `ToggleTab` | Toggle between current and last active tab (`last-window`) |
| `Ctrl-a` `,` | `RenameTab` | Prompt to rename current tab |
| `Ctrl-a` `&` or `X` | `CloseTab` | Close current tab |

### Pane Management

| Shortcut | Action | Description |
|---|---|---|
| `Ctrl-a` `"` or `-` | `NewPane "Down"` | Split pane horizontally (below) |
| `Ctrl-a` `%` or `\|` or `\` | `NewPane "Right"` | Split pane vertically (right) |
| `Ctrl-a` `h` / `j` / `k` / `l` | `MoveFocus` | Move focus left / down / up / right |
| `Ctrl-a` `Left` / `Down` / `Up` / `Right` | `MoveFocus` | Move focus with arrow keys |
| `Alt` `h` / `j` / `k` / `l` | `MoveFocus` | Direct 1-stroke move focus (no prefix) |
| `Ctrl-a` `z` | `ToggleFocusFullscreen` | Zoom / toggle fullscreen on active pane |
| `Ctrl-a` `x` | `CloseFocus` | Close focused pane |
| `Ctrl-a` `o` | `FocusNextPane` | Cycle focus to next pane |
| `Ctrl-a` `;` | `FocusLastPane` | Focus last active pane |
| `Ctrl-a` `{` / `}` | `MovePaneBackwards` / `MovePane` | Swap/reorder pane position |
| `Ctrl-a` `!` | `BreakPane` | Break active pane into its own new tab |
| `Ctrl-a` `Space` | `NextSwapLayout` | Cycle through defined tiled layouts |
| `Ctrl-a` `w` | `ToggleFloatingPanes` | Toggle floating panes overlay |

### Scrollback & Copy Mode

| Shortcut | Action | Description |
|---|---|---|
| `Ctrl-a` `[` | `SwitchToMode "Scroll"` | Enter scrollback / copy mode |
| `j` / `k` (or `Down` / `Up`) | `ScrollDown` / `ScrollUp` | Scroll line by line |
| `d` / `u` | `HalfPageScrollDown` / `Up` | Half page scroll down / up |
| `Ctrl-f` / `Ctrl-b` | `PageScrollDown` / `Up` | Full page scroll down / up |
| `[` / `]` | Prompt navigation | Jump to previous / next shell prompt |
| `/` | `EnterSearch` | Search scrollback (`n` next, `N` prev) |
| `e` | `EditScrollback` | Open full scrollback in `$EDITOR` (Neovim) |
| `q` / `Esc` / `Ctrl-c` | `ScrollToBottom` + Lock | Exit scroll mode back to application |

### Session & Utilities

| Shortcut | Action | Description |
|---|---|---|
| `Ctrl-a` `s` | `zellij:session-manager` | Interactive session manager |
| `Ctrl-a` `d` | `Detach` | Detach session (leaves processes running) |
| `Ctrl-a` `a` | Literal `Ctrl-a` | Send `\x01` to Neovim (`<C-a>`) or shell (`BOL`) |
| `Ctrl-a` `f` | `zellij:strider` | Floating file explorer |
| `Ctrl-a` `?` | `zellij-forgot` | Searchable keybinding cheat sheet |
| `Ctrl-a` `Esc` / `q` | `SwitchToMode "Locked"` | Cancel prefix |

### Advanced Sub-Modes

| Shortcut | Action | Description |
|---|---|---|
| `Ctrl-a` `r` | `SwitchToMode "Resize"` | Interactive resize (`h/j/k/l`, `+/-`; `Enter`/`Esc`/`q` to exit) |
| `Ctrl-a` `m` | `SwitchToMode "Move"` | Interactive pane reordering (`Enter`/`Esc`/`q` to exit) |
| `Ctrl-a` `t` | `SwitchToMode "Tab"` | Dedicated Zellij tab mode |
| `Ctrl-a` `P` | `SwitchToMode "Pane"` | Dedicated Zellij pane mode |

---

## Layouts & Status Bar

- **Status Bar (`zjstatus`)**: Minimalist status bar styled in **Rose Pine**. Displays the session name, tab bar, active mode badge (`LOCKED`, `TMUX`, `SCROLL`, etc.), and time.
- **Layouts**:
  - `default.kdl`: Standard single pane with bottom status bar.
  - `omp.kdl` (`dev.kdl`): 60/40 split with Neovim on the left, Oh My Pi on the right, and a secondary terminal tab.
