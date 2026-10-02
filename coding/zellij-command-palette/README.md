# Zellij Command Palette

A small Rust/WASM plugin for fuzzy-searching a fixed set of Zellij actions.

Available actions:

- New Tab
- New Pane
- Next Tab
- Previous Tab

Search is case-insensitive and matches command names and aliases.

## Permission boundary

The plugin requests only Zellij's `ChangeApplicationState` permission. It uses that permission for the four built-in actions above. It does not read or write files, access the network or session environment, or run arbitrary commands. New Pane uses Zellij's built-in API to open the configured default shell.

## Build and test

Install the WASI target once, then build and test:

```sh
rustup target add wasm32-wasip1
cargo test --locked
cargo fmt --check
cargo build --locked --release --target wasm32-wasip1 --bin zellij-command-palette
```

The project uses Zellij's `zellij-tile` SDK at version `0.45.1`. The prebuilt artifact is in `dist/zellij_command_palette.wasm`; refresh it after source changes:

```sh
mkdir -p dist
cp target/wasm32-wasip1/release/zellij-command-palette.wasm dist/zellij_command_palette.wasm
(cd dist && shasum -a 256 zellij_command_palette.wasm > SHA256SUMS)
```

Verify the artifact checksum with `(cd dist && shasum -a 256 -c SHA256SUMS)`.

## Install in Zellij

Copy the WASM file into Zellij's plugin directory:

```sh
mkdir -p ~/.config/zellij/plugins
cp dist/zellij_command_palette.wasm ~/.config/zellij/plugins/zellij_command_palette.wasm
```

Register the alias in `config.kdl`:

```kdl
plugins {
    zellij-command-palette location="file:~/.config/zellij/plugins/zellij_command_palette.wasm"
}
```

In the desired keybind mode, bind `g` to the alias:

```kdl
bind "g" {
    LaunchOrFocusPlugin "zellij-command-palette" {
        floating true
        move_to_focused_tab true
    }
    SwitchToMode "Locked"
}
```

Restart Zellij after changing the plugin alias. The first launch prompts for the plugin's requested application-state permission.
