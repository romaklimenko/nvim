# Neovim for a Danish keyboard

## Overview

A shared macOS, Windows, and Linux/WSL setup with familiar editing shortcuts, file tabs,
Telescope search, and reachable Space-key menus. The leader key is Space.
Press Space in normal mode and pause to see available shortcuts.

## Features

- **Search:** project files and text through Telescope, with Git-root detection.
- **Tabs:** Enter opens file results in a tab. The first file reuses an empty tab.
- **Multiple cursors:** select the next occurrence or every match, including Danish text.
- **Git:** changed-file list with diff previews, gutter signs, and hunk navigation.
- **Editing:** platform-appropriate save/undo/redo aliases, highlighted search, and persistent undo history.
- **Theme:** onedark.nvim with the existing deep style.
- **Languages:** Treesitter highlighting and Mason-managed Python/Rust language servers.
- **Discovery:** which-key menus and a searchable list of keyboard shortcuts.

## Setup

1. Install Neovim 0.11.3 or newer, Git, and ripgrep.
2. Place this repository at the configuration path, or link that path to this checkout:
   - Windows: `%LOCALAPPDATA%\nvim`
   - macOS and Linux/WSL: `~/.config/nvim`
3. Start Neovim. lazy.nvim installs missing plugins automatically.
4. Restore the pinned plugin versions with `nvim --headless "+Lazy! restore" +qa`.
5. Run `:checkhealth` to check dependencies.

When installed through the dotfiles submodule, the configuration link picks up
edits immediately. Restart existing Neovim sessions after plugin or mapping changes.
Treesitter stays on its `master` configuration API. The lockfile pins plugin versions. Use `:Lazy update` only when intentionally upgrading.

### macOS installation

Install prerequisites with `brew install neovim ripgrep` and, if needed,
`xcode-select --install` for Git and the parser compiler. Use the Danish input
source as usual; no keyboard-layout switch is required.

Keep a checkout wherever convenient and link it to the standard config path:

```sh
git clone https://github.com/romaklimenko/nvim.git ~/Developer/nvim
mkdir -p ~/.config
# If ~/.config/nvim already exists, move it to a backup first.
ln -s ~/Developer/nvim ~/.config/nvim
```

On Windows, either clone directly into `$env:LOCALAPPDATA\nvim` or link that
path to the same repository's Windows checkout. Each machine has its own plugin
and language-server data; only the configuration and lockfile are shared.

### Keyboard style

- **macOS default:** Command aliases plus native Neovim Ctrl keys. Ctrl+D/F
  scroll, Ctrl+W remains the window prefix, and insert-mode Ctrl+P completes.
- **Windows/WSL default:** keep this repo's existing VS Code-like Ctrl aliases.
- On either OS, set environment variable `NVIM_KEYMAP_STYLE=native` to preserve
  native Ctrl bindings, or `NVIM_KEYMAP_STYLE=vscode` to enable the Ctrl aliases.
  For example, `NVIM_KEYMAP_STYLE=native nvim` on Mac/WSL; in PowerShell,
  `$env:NVIM_KEYMAP_STYLE = 'native'` before starting Neovim.
- Command aliases and Space menus remain available in both styles. Restart
  Neovim after changing style; re-sourcing init.lua does not remove old mappings.

### Dependencies

- **ripgrep:** required for project text search. Windows:
  `winget install BurntSushi.ripgrep.MSVC`. Ubuntu/WSL: `sudo apt install ripgrep`.
- **Nerd Font:** use a Nerd Font in the terminal to display file icons.
- **C compiler:** needed for Treesitter parsers. Use Visual Studio Build Tools or
  Zig on Windows, Xcode Command Line Tools on macOS, and `build-essential` on Ubuntu.
- **Language servers:** Mason manages pyright and rust-analyzer. Open `:Mason`
  to inspect their installation status. Server settings use Neovim’s native LSP
  configuration API, as required by the pinned mason-lspconfig v2.

## Everyday shortcuts

These operate in normal, insert, and visual modes unless noted. Space-key
sequences start in normal mode. Press Escape first when typing text.

| Action | Mac alias | Windows/VS Code style | Portable alternative |
| --- | --- | --- | --- |
| Find project files | Cmd+P | Ctrl+P | Space f f |
| Command palette | Cmd+Shift+P | Ctrl+Shift+P | Space f p |
| Find project text | Cmd+Shift+F | Ctrl+Shift+F | Space f g or F4 |
| Find in this file | Cmd+F | Ctrl+F | / for native search; Space f l for line picker |
| Next / previous search match (normal/insert) | F3 / Shift+F3 | F3 / Shift+F3 | n / N |
| Select word, then next match | Cmd+D, repeated | Ctrl+D, repeated | Space m n |
| Select every occurrence | Cmd+Shift+L | Ctrl+Shift+L | Space m a or F7 |
| Undo / redo | Cmd+Z / Cmd+Shift+Z | Ctrl+Z / Ctrl+Y | u / Ctrl+R |
| Save | Cmd+S | Ctrl+S | Space s |
| Close current tab | Cmd+W | Ctrl+W | Space x |
| Next / previous tab | Ctrl+Tab / Ctrl+Shift+Tab | Ctrl+Tab / Ctrl+Shift+Tab | Tab / Shift+Tab in normal mode, or F8 / Shift+F8 |
| Git changes and diffs | Ctrl+Shift+G or Cmd+Shift+G | Ctrl+Shift+G | Space g g or F6 |
| Project explorer | Cmd+Shift+E | Ctrl+Shift+E | Space e |
| Toggle reusable terminal | Ctrl+æ | Ctrl+æ | Space t t |
| Look up a shortcut | Space f k | Space f k | Pause after Space for the menu |

Ctrl+Tab cycles tabs in display order; it is not VS Code's recently-used-file
switcher. Use Space b for the alternate buffer and Space f b for a buffer picker.
The command palette lists Neovim Ex commands; Space f k searches mapped actions.

**Terminal forwarding matters.** Cmd (`<D-...>` in Lua), Ctrl+Tab,
Ctrl+Shift+letters, and Ctrl+æ work only if the terminal or GUI sends them to
Neovim. A Lua mapping cannot override a shortcut captured by the terminal.
macOS Terminal may use Cmd+P for printing and Cmd+W for closing its window;
Windows Terminal captures some Ctrl shortcuts. Use the Space alternatives
without changing terminal settings. A GUI such as Neovide can forward Command
keys; modern terminals may need their own key/protocol configuration.

Keep Option available for typing Danish-layout programming symbols. Do not
turn both Option keys into Alt/Meta merely to make editor shortcuts work.
No required shortcut uses Option/AltGr, brackets, or Ctrl plus a Danish letter;
Ctrl+æ is an optional alias. Plain æ, ø, and å remain ordinary text.
On laptop keyboards, function keys may require Fn.

Only in VS Code Ctrl style: Ctrl+W replaces the window prefix, Ctrl+D/F replace
scrolling, Ctrl+Z undoes instead of suspending, and insert-mode Ctrl+P opens
files instead of completion. Split navigation remains on Ctrl+H/J/K/L and
Space w. Insert-mode Find leaves insert mode to search.

### Which habits to keep

Use a hybrid. File pickers, project search, Git, an explorer, and a terminal are
application actions: familiar aliases are useful. For editing, learn the small
native vocabulary that composes well:

- `/text`, Enter, `n` / `N`: search and move between matches.
- `ciw`: change the word under the cursor; `.` repeats an edit.
- `/text`, Enter, `cgn`, replacement, Escape, then `.`: change successive search
  matches. Use `n` to skip one. This is sequential editing, not multiple cursors.
- Space r n: language-server rename for a code symbol (when a server is attached).
- `:%s/old/new/gc`: replace text throughout the file, confirming each match.

Keep multicursors for arbitrary repeated text. Prefer semantic rename for code
symbols when available. The Space menus are this configuration's shortcuts;
Neovim itself supplies `/`, `n`, `ciw`, `cgn`, `.`, and `:s`. There are common fast
workflows, but they usually use consecutive keys in normal mode instead of chords.

Sources: [Neovim key notation](https://neovim.io/doc/user/intro/#key-notation),
[terminal input](https://neovim.io/doc/user/tui/#tui-input),
[search selections](https://neovim.io/doc/user/visual/#gn),
[Neovide Command keys](https://neovide.dev/faq.html), and
[Option handling](https://ghostty.org/docs/config/reference#macos-option-as-alt).

### Search

Cmd+F (Ctrl+F in VS Code style) opens a highlighted, literal search. Type text and press Enter, then use
F3 and Shift+F3 to move between matches. Escape clears highlights in normal mode.
The search uses Vim's very-nomagic mode: escape a literal slash or backslash.
The ordinary / command remains available for regular expressions.

F4 searches the current file's Git project, including when Neovim started in a
subdirectory. Without a Git root, it searches Neovim's working directory.
Project search treats the query as literal text and respects .gitignore.
Search is case-insensitive unless the query contains an uppercase letter.

### Multiple selections

1. Put the cursor on a word and press Cmd+D (Ctrl+D in VS Code style) to select it.
2. Press the same shortcut again to add the next occurrence. F7 selects every occurrence.
   You can also select a phrase with v before adding matches.
3. Press c, type the replacement, then press Escape to finish typing.
4. Press Escape again to clear the extra cursors. Cmd+Z, Ctrl+Z in VS Code style, or normal-mode u undoes the edit.

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

Cmd+W (Ctrl+W in VS Code style) refuses to close a tab containing unsaved changes. Save the affected
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
| Space e | Toggle the built-in netrw project explorer |
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
| Space t t | Show/hide the same terminal shell |
| Space t v / Space t s | Vertical / horizontal terminal |
| Ctrl+G in a terminal buffer | Leave terminal input mode |

Format moved from Space f to Space f m. Relative numbers moved from Space t
to Space u n. Splits moved from Space s v/h/x/o to Space w v/h/x/o.
These changes let file, tab, and save shortcuts respond without prefix conflicts.
Terminal mode also accepts Ctrl+Space to return to normal mode when forwarded.

### Explorer and terminal

Space e opens a project tree using Neovim's built-in netrw. Enter expands a
folder or opens a file in a new tab. Repeat Space e to hide the sidebar.

Space t t opens a bottom terminal, hides it, or shows the same running shell.
Ctrl+æ performs the same action, including from terminal input, when forwarded.
The portable way to hide it while typing shell commands is Ctrl+G, then Space t t.
macOS uses executable `$SHELL` (normally zsh), then zsh/bash/sh fallbacks;
Windows uses pwsh, powershell, then cmd.exe. An exited toggle shell is recreated
on the next open. Space t v and Space t s still create independent terminals.

### Language-server shortcuts

When a server is attached: gd goes to definition, gD to declaration, gi to
implementation, gr to references, and K shows documentation. Space r n renames
a symbol, Space c a opens code actions, and Space d shows diagnostics.
[d and ]d remain available for previous and next diagnostics.

## Validation

After installing plugins, run from this repository:

```sh
nvim --headless -u NONE -i NONE -l tests/keymaps.lua
nvim --headless -u NONE -i NONE -l tests/terminal.lua
nvim --headless -u NONE -i NONE -l tests/explorer.lua
nvim --headless -u NONE -i NONE -l tests/workflow.lua
```

The workflow tests use a separate Neovim process and real input events. They check
multicursor edits with Danish text, undo/redo, literal searches, safe tab closing,
and Telescope's Enter behavior. They do not modify user files.
Set `NVIM_TEST_PLUGINS` to test against a different installed lazy.nvim plugin directory.

The other checks cover platform/style selection, terminal reuse and shell fallbacks,
and explorer behavior with spaces and Danish filenames. Windows shell selection
is simulated when running on macOS; real Windows execution still needs a Windows check.
