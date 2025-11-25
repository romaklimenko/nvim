# Minimal Neovim Configuration (Danish ThinkPad)

## Overview
This is a minimal Neovim setup tailored for a Danish keyboard on Lenovo ThinkPad hardware. It runs on both Windows (`%LOCALAPPDATA%\nvim`) and Linux (`~/.config/nvim`). Mappings avoid awkward chords on the Danish layout and keep navigation reachable on laptop keyboards.

## Setup
1) Install Neovim 0.9+ and ensure it is on your `PATH`.
2) Back up any existing config, then place this repo at `%LOCALAPPDATA%\nvim` (Windows) or `~/.config/nvim` (Linux).
3) Start Neovim once (`nvim`) to let the plugin manager bootstrap if `init.lua` enables one. Then sync plugins with the matching command: `nvim --headless "+Lazy sync" +qa` or `nvim --headless "+PackerSync" +qa`.
4) Run `nvim --headless "+checkhealth" +qa` to verify dependencies. Resolve any missing tools reported there.

## Dependencies
For full Telescope functionality (live grep):
- **Windows**: `winget install BurntSushi.ripgrep.MSVC` (restart your shell after installation)
- **Linux**: `sudo apt install ripgrep` (Debian/Ubuntu) or `sudo pacman -S ripgrep` (Arch) or use your distro's package manager

## LSP Support
Language servers are automatically installed via Mason for:
- **Python** - pyright
- **Rust** - rust-analyzer
- **TypeScript/JavaScript** - ts_ls
- **Go** - gopls

LSP servers install automatically on first use. You can manually manage them with `:Mason`.

## Hotkeys
Leader: `<Space>` (kept easy to hit on Danish layout).

### File Explorer (nvim-tree)
- `<Space>e` — toggle file explorer (nvim-tree with icons).
  - In nvim-tree: `Enter` to open, `a` to create, `d` to delete, `r` to rename, `?` for help.

### Basic Operations
- `<Space>s` — save the current buffer.
- `<Space>q` — close the current window or quit if it is the last.
- `<Space>f` - format the current buffer via LSP/formatter.
- `<Space>r` - reload `init.lua` to pick up config changes.
- `<Space>t` - toggle relative line numbers for quick motion alignment.
- `<Space>b` - switch to the most recent buffer (`:b#`).

### Navigation
- `<C-h>/<C-j>/<C-k>/<C-l>` - move across splits (left/down/up/right) using home-row friendly keys.

### Tab Management
- `<Space>tn` - create new tab.
- `<Space>tx` - close current tab.
- `<Space>to` - close all other tabs.
- `<Tab>` - next tab.
- `<Shift-Tab>` - previous tab.

### Split Management
- `<Space>sv` - split vertically.
- `<Space>sh` - split horizontally.
- `<Space>sx` - close current split.
- `<Space>so` - close all other splits.

### Resize Splits
- `<C-Up>` - increase split height.
- `<C-Down>` - decrease split height.
- `<C-Left>` - decrease split width.
- `<C-Right>` - increase split width.

### Terminal
- `<Space>tv` - open a vertical terminal using PowerShell on Windows or your login shell on Linux.
- `<Space>ts` - open a horizontal terminal pane (PowerShell or login shell, matching the current OS).
- `<C-g>` in terminal buffers - leave terminal insert mode (Danish-friendly alternative to `<C-\><C-n>`; `<C-Space>` also works if your terminal sends it).

### Telescope (Fuzzy Finding)
- `<Space>ff` - find files (press `<C-t>` to open in new tab, `<C-v>` for vertical split, `<C-x>` for horizontal split).
- `<Space>fg` - live grep / search in files.
- `<Space>fb` - find buffers.
- `<Space>fh` - search help tags.

### LSP (when attached to buffer)
- `gd` - go to definition.
- `gD` - go to declaration.
- `gi` - go to implementation.
- `gr` - find references.
- `K` - show hover documentation.
- `<Space>rn` - rename symbol.
- `<Space>ca` - code actions.
- `<Space>d` - show diagnostic in floating window.
- `[d` - previous diagnostic.
- `]d` - next diagnostic.

Update this list whenever mappings change so it stays accurate for contributors.
