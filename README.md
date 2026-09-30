# Neovim for a Danish keyboard

## Overview

A small Windows and Linux/WSL setup with familiar editing shortcuts, file tabs,
Telescope search, and reachable Space-key menus. The leader key is Space.
Press Space in normal mode and pause to see available shortcuts.

## Features

- **Search:** project files and text through Telescope, with Git-root detection.
- **Tabs:** Enter opens file results in a tab. The first file reuses an empty tab.
- **Multiple cursors:** select the next occurrence or every match, including Danish text.
- **Git:** changed-file list with diff previews, gutter signs, and hunk navigation.
- **Editing:** Ctrl+S, Ctrl+Z, Ctrl+Y, highlighted search, and persistent undo history.
- **Theme:** onedark.nvim with the existing deep style.
- **Languages:** Treesitter highlighting and Mason-managed Python/Rust language servers.
- **Discovery:** which-key menus and a searchable list of keyboard shortcuts.

## Setup

1. Install Neovim 0.11.3 or newer, Git, and ripgrep.
2. Place this repository at the configuration path, or link that path to this checkout:
   - Windows: `%LOCALAPPDATA%\nvim`
   - Linux/WSL: `~/.config/nvim`
3. Start Neovim. lazy.nvim installs missing plugins automatically.
4. Restore the pinned plugin versions with `nvim --headless "+Lazy! restore" +qa`.
5. Run `:checkhealth` to check dependencies.

When installed through the dotfiles submodule, the configuration link picks up
edits immediately. Restart existing Neovim sessions after plugin or mapping changes.
The lockfile pins plugin versions. Use `:Lazy update` only when intentionally upgrading.

### Dependencies

- **ripgrep:** required for project text search. Windows:
  `winget install BurntSushi.ripgrep.MSVC`. Ubuntu/WSL: `sudo apt install ripgrep`.
- **Nerd Font:** use a Nerd Font in the terminal to display file icons.
- **C compiler:** needed for Treesitter parsers. Use Visual Studio Build Tools or
  Zig on Windows, and `build-essential` on Ubuntu.
- **Language servers:** Mason manages pyright and rust-analyzer. Open `:Mason`
  to inspect their installation status.

## Everyday shortcuts

These operate in normal, insert, and visual modes unless noted. Space-key
sequences start in normal mode. Press Escape first when typing text.

| Action | Familiar shortcut | Reliable alternative |
| --- | --- | --- |
| Find project files | Ctrl+P | Space f f |
| Find text across the project | Ctrl+Shift+F | F4 or Space f g |
| Find text in this file | Ctrl+F | Space f l for a Telescope line picker |
| Next / previous search match | F3 / Shift+F3 | n / N in normal mode |
| Select current word, then next match | Ctrl+D, repeated | Space m n |
| Select every occurrence | Ctrl+Shift+L | F7 or Space m a |
| Undo / redo | Ctrl+Z / Ctrl+Y | u / Ctrl+R in normal mode |
| Save | Ctrl+S | Space s |
| Close current tab | Ctrl+W | Space x |
| Next / previous tab | Ctrl+Tab / Ctrl+Shift+Tab | F8 / Shift+F8, or Tab / Shift+Tab in normal mode |
| Show changed files and diffs | Ctrl+Shift+G | F6 or Space g g |
| Look up a shortcut | Space f k | Pause after Space for the menu |

Windows Terminal uses Ctrl+Shift+F for its own search and Ctrl+Tab for terminal
tabs. Some terminals also send Ctrl+Shift+letters as plain Ctrl+letters.
Use the alternatives above when a shortcut is intercepted. Terminal shortcuts
do not need to be changed. On laptop keyboards with hardware actions on function
keys, hold Fn or use the Space sequences. No new shortcut needs AltGr, brackets,
or Ctrl plus a Danish letter.

Ctrl+W replaces Neovim's window-command prefix. Split navigation remains on
Ctrl+H/J/K/L and the Space w menu. Ctrl+D replaces half-page scrolling.
Ctrl+Z now undoes instead of suspending Neovim. Insert-mode Ctrl+F leaves insert
mode to search. F3 and Shift+F3 work in normal and insert modes.

### Search

Ctrl+F opens a highlighted, literal search. Type text and press Enter, then use
F3 and Shift+F3 to move between matches. Escape clears highlights in normal mode.
The search uses Vim's very-nomagic mode: escape a literal slash or backslash.
The ordinary / command remains available for regular expressions.

F4 searches the current file's Git project, including when Neovim started in a
subdirectory. Without a Git root, it searches Neovim's working directory.
Project search treats the query as literal text and respects .gitignore.
Search is case-insensitive unless the query contains an uppercase letter.

### Multiple selections

1. Put the cursor on a word and press Ctrl+D to select it.
2. Press Ctrl+D again to add the next occurrence. F7 selects every occurrence.
   You can also select a phrase with v before adding matches.
3. Press c, type the replacement, then press Escape to finish typing.
4. Press Escape again to clear the extra cursors. Ctrl+Z undoes the edit.

Space m s skips an occurrence. Space m j and Space m k add cursors below and
above. Space m c clears extra cursors.

### Telescope

For file pickers, project search, buffers, recent files, and Git status:

- Enter or Ctrl+T opens the selected result in a tab, in either picker mode.
- An empty tab is reused for the first file.
- Ctrl+O opens the selected file in the current tab.
- Ctrl+V opens a vertical split. Ctrl+X opens a horizontal split.
- Ctrl+J/K or arrow keys move through results.
- Escape leaves the input field. A second Escape closes the picker.

In-file line search, help, commands, and shortcut pickers keep their normal
Enter action. Searching inside a file does not create another tab.

### Tabs and unsaved changes

Ctrl+W refuses to close a tab containing unsaved changes. Save the affected
buffers first. Closing the last tab leaves an empty tab with Neovim still open.
Tabs are views: closing a tab can leave its saved buffers in Space f b.

- Space t n: new empty tab.
- Space t x: close current tab.
- Space t o: close all other tabs. Hidden buffers remain available in Space f b.
- Tab / Shift+Tab: next / previous tab in normal mode. Insert-mode Tab still indents.

### Git changes

F6 lists staged, unstaged, and untracked files with a diff preview.
Enter opens the selected file in a tab. In this Git picker, Tab toggles staging
for the selected file, following Telescope's default behavior.

- Space g h: preview the change under the cursor.
- Space g n / Space g p: next / previous change.
- Gutter signs show changed lines in Git-tracked files.

### Other Space menus

| Keys | Action |
| --- | --- |
| Space e | Find files beside the current file |
| Space f a | Find files including gitignored files |
| Space f b | Find open buffers |
| Space f h | Search help |
| Space f m | Format with the attached language server |
| Space b | Switch to the previous buffer |
| Space q / Space q a | Quit window / quit all, with confirmation for unsaved work |
| Space r | Source init.lua again |
| Space u n | Toggle relative line numbers |
| Space w v / Space w h | Vertical / horizontal split |
| Space w x / Space w o | Close split / close other splits |
| Ctrl+arrow keys | Resize splits |
| Space t v / Space t s | Vertical / horizontal terminal |
| Ctrl+G in a terminal buffer | Leave terminal input mode |

Format moved from Space f to Space f m. Relative numbers moved from Space t
to Space u n. Splits moved from Space s v/h/x/o to Space w v/h/x/o.
These changes let file, tab, and save shortcuts respond without prefix conflicts.
Terminal mode also accepts Ctrl+Space to return to normal mode when forwarded.

### Language-server shortcuts

When a server is attached: gd goes to definition, gD to declaration, gi to
implementation, gr to references, and K shows documentation. Space r n renames
a symbol, Space c a opens code actions, and Space d shows diagnostics.
[d and ]d remain available for previous and next diagnostics.

## Validation

After installing plugins, run from this repository:

```sh
nvim --headless -u NONE -i NONE -l tests/workflow.lua
```

The tests use a separate Neovim process and real input events. They check
multicursor edits with Danish text, undo/redo, literal searches, safe tab closing,
and Telescope's Enter behavior. They do not modify user files.
Set `NVIM_TEST_PLUGINS` to test against a different installed lazy.nvim plugin directory.
