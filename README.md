# Minimal Neovim Configuration (Danish ThinkPad)

## Overview
This is a minimal Neovim setup tailored for a Danish keyboard on Lenovo ThinkPad hardware. It runs on both Windows (`%LOCALAPPDATA%\nvim`) and Linux (`~/.config/nvim`). Mappings avoid awkward chords on the Danish layout and keep navigation reachable on laptop keyboards.

## Features
- **Theme**: [onedark.nvim](https://github.com/navarasu/onedark.nvim) with 'deep' style for clean, dark appearance
- **Syntax Highlighting**: Treesitter for accurate, fast syntax highlighting and code understanding
- **File Browser**: Telescope file browser extension for integrated file navigation
- **Fuzzy Finding**: Telescope for fast file and content search
- **LSP**: Mason-managed language servers for Rust and Python

## Setup
1) Install Neovim 0.9+ and ensure it is on your `PATH`.
2) Back up any existing config, then place this repo at `%LOCALAPPDATA%\nvim` (Windows) or `~/.config/nvim` (Linux).
3) Start Neovim once (`nvim`) to let the plugin manager bootstrap if `init.lua` enables one. Then sync plugins with the matching command: `nvim --headless "+Lazy sync" +qa` or `nvim --headless "+PackerSync" +qa`.
4) Run `nvim --headless "+checkhealth" +qa` to verify dependencies. Resolve any missing tools reported there.

## Dependencies

### Required for icons (file browser, statusline, etc.)
- **Nerd Font**: Required for proper icon display in terminal
  - **Windows Terminal**:
    1. Install a Nerd Font: `winget install -e --id JanDeDobbeleer.OhMyPosh` (includes fonts) OR download from [Nerd Fonts](https://www.nerdfonts.com/font-downloads) (recommended: CaskaydiaCove, JetBrainsMono, or FiraCode)
    2. Open Windows Terminal Settings (Ctrl+,)
    3. Go to Profiles → Defaults → Appearance
    4. Set "Font face" to a Nerd Font (e.g., "CaskaydiaCove Nerd Font")
    5. Click Save and restart terminal
  - **Linux**: Install via package manager (e.g., `sudo apt install fonts-firacode fonts-jetbrains-mono`) or download from [Nerd Fonts](https://www.nerdfonts.com/)

### For Telescope live grep
- **Windows**: `winget install BurntSushi.ripgrep.MSVC` (restart your shell after installation)
- **Linux**: `sudo apt install ripgrep` (Debian/Ubuntu) or `sudo pacman -S ripgrep` (Arch) or use your distro's package manager

### For Treesitter syntax highlighting
- **Windows**: Install either:
  - Visual Studio Build Tools: `winget install Microsoft.VisualStudio.2022.BuildTools` (select "Desktop development with C++")
  - Or install `zig`: `winget install zig.zig` (lightweight alternative)
- **Linux**: Usually pre-installed (gcc), or `sudo apt install build-essential` (Debian/Ubuntu)

## LSP Support
Language servers are automatically installed via Mason for:
- **Python** - pyright
- **Rust** - rust-analyzer

LSP servers install automatically on first use. You can manually manage them with `:Mason`.

## Hotkeys
Leader: `<Space>` (kept easy to hit on Danish layout).

### File Browser
- `<Space>e` — open Telescope file browser in current directory.
  - In file browser: `Enter` to open, `c` to create, `d` to delete, `r` to rename, `?` for help.

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
