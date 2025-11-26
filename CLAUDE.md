# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
Minimal Neovim configuration for Danish keyboard on Lenovo ThinkPad. Cross-platform: Windows (`%LOCALAPPDATA%\nvim`) and Linux/WSL (`~/.config/nvim`). All keymaps avoid awkward chords on Danish layout.

## Architecture
- **Entry**: `init.lua` sets leader and loads modules from `lua/`
- **Modules**: `lua/editor/options.lua` (settings), `lua/editor/keymaps.lua` (bindings), `lua/editor/terminal.lua` (cross-platform shell spawning)
- **Pattern**: All modules export `M.setup()` called from `init.lua` via `require("module.path").setup()`

### Terminal System
`terminal.lua` detects platform and spawns appropriate shell:
- Windows: `pwsh` or `powershell` with `-NoLogo`
- Linux: `$SHELL` → `bash` → `sh` fallback
- Functions: `open_vertical()`, `open_horizontal()`, `open_tab()`

## Development Commands
- `nvim` - Launch and test manually
- `nvim --headless "+checkhealth" +qa` - Verify dependencies
- `nvim --headless "+Lazy sync" +qa` - Sync plugins (if Lazy.nvim added)
- `stylua lua/ init.lua` - Format Lua files

## Coding Style
- 2-space indent, no tabs
- Module names match features (`editor/options.lua`)
- All keymaps have `{ desc = "..." }` for discoverability
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`

## Platform Notes
- Test on both Windows and WSL to catch shell/path issues
- Use `/` in paths (works cross-platform) or `vim.fn.stdpath()`
- Shell commands as arrays: `{ "pwsh", "-NoLogo" }`
- Platform check: `vim.fn.has("win32") == 1`

## Key Constraints
- Keep mappings reachable on Danish layout (avoid awkward chords)
- README hotkeys must stay in sync with `lua/editor/keymaps.lua`
- Leader is `<Space>`; terminal escape is `<C-g>` (not `<C-\><C-n>`)
- **IMPORTANT**: Always update README.md when making configuration changes (LSP servers, plugins, keymaps, etc.)
