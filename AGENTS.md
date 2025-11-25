# Repository Guidelines

## Platform & Keyboard Context
- Minimalistic Neovim configuration tuned for a Danish keyboard on Lenovo ThinkPad hardware; keep mappings reachable without awkward chords on that layout.
- Primary platforms: Windows (`%LOCALAPPDATA%\nvim`) and Linux (`~/.config/nvim`). Validate changes in both to avoid path or shell-specific regressions.
- README must stay current with hotkeys and any setup prerequisites; update it whenever mappings or bootstrap steps change.

## Project Structure & Module Organization
- Core entrypoint is `init.lua` at the root; reusable modules live in `lua/`, keyed by feature (e.g., `lua/ui/`, `lua/editor/`).
- Runtime tweaks can go in `after/` for late-loading settings, and `ftplugin/` for filetype-specific opts. Custom commands or autocmds belong in `plugin/`.
- Place assets such as snippets or templates under `snippets/` or `templates/`, keeping names aligned to filetype (e.g., `go.snippets`).
- Tests (if present) should sit in `tests/` with minimal init files under `tests/minimal_init.lua` to keep fixtures isolated.

## Build, Test, and Development Commands
- `nvim` launches the config interactively for manual verification (test Danish-layout reachability of hotkeys).
- `nvim --headless "+checkhealth" +qa` runs Neovim health checks to spot missing deps or miswired plugins.
- `nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests" +qa` executes Lua tests via plenary; adjust the init path if you add a different harness.
- `nvim --headless "+PackerSync" +qa` (or `+Lazy sync` if using Lazy) refreshes plugins; use the manager that matches `init.lua`.

## Coding Style & Naming Conventions
- Lua files use 2-space indent, no tabs; prefer descriptive module names (`lua/editor/options.lua`, `lua/plugins/treesitter.lua`).
- Keep options and keymaps grouped by feature; avoid global variables; expose module tables instead.
- Use `stylua` for formatting when available (`stylua lua/ init.lua`).
- Plugin specs should be deterministic: pin commit hashes where stability matters and order setups in `lua/plugins/` by dependency.

## Testing Guidelines
- Name tests after the module under test (`tests/editor/options_spec.lua`).
- Keep fixtures small; mock external tools when possible to keep headless runs fast.
- Aim for coverage on keymaps, commands, and custom Lua helpers; verify startup stays under a couple hundred ms in `:startup` when adding heavy plugins.

## Commit & Pull Request Guidelines
- Use concise Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`) so changelog tooling can parse history.
- Commits should remain focused: one behavioral change or logical refactor per commit.
- PRs need a short summary, screenshots or asciinema for UI changes, and mention any new dependencies or breaking defaults.
- Link issues in PR descriptions using `Closes #ID`; note verification steps (healthcheck, headless tests) so reviewers can reproduce quickly.
