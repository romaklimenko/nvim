local M = {}

local terminal = require("editor.terminal")
local shortcuts = require("editor.shortcuts")

function M.project_root()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or vim.bo.buftype ~= "" then
    path = vim.uv.cwd()
  end
  -- .git can be a file in submodules and worktrees.
  return vim.fs.root(path, ".git") or vim.uv.cwd()
end

function M.close_tab()
  local tab = vim.api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].modified then
      vim.notify("Unsaved changes in this tab. Save with Space s before closing.", vim.log.levels.WARN)
      return
    end
  end
  -- Keep Neovim open with an empty tab when closing the last file.
  if #vim.api.nvim_list_tabpages() == 1 then
    vim.cmd.tabnew()
    vim.api.nvim_set_current_tabpage(tab)
  end
  vim.cmd.tabclose()
end

local function picker(name, options)
  return function()
    require("telescope.builtin")[name](vim.tbl_extend("force", { cwd = M.project_root() }, options or {}))
  end
end

function M.setup()
  local function map(mode, keys, action, description)
    vim.keymap.set(mode, keys, action, { silent = true, desc = description })
  end
  local editing_modes = { "n", "i", "x" }
  local find_files = picker("find_files")
  local search_project = picker("live_grep", { additional_args = { "--fixed-strings" } })
  local git_changes = picker("git_status")
  local commands = picker("commands")
  local explorer = function()
    require("editor.explorer").toggle(M.project_root())
  end
  local familiar = shortcuts.map

  -- Function keys work when the terminal captures Ctrl+Shift or Ctrl+Tab.
  familiar(editing_modes, "<C-p>", "<D-p>", find_files, "Find project files")
  familiar(editing_modes, "<C-S-f>", "<D-S-f>", search_project, "Search project text")
  map(editing_modes, "<F4>", search_project, "Search project text")
  familiar(editing_modes, "<C-S-g>", "<D-S-g>", git_changes, "Git changed files and diffs")
  map(editing_modes, "<F6>", git_changes, "Git changed files and diffs")

  familiar(editing_modes, "<C-S-p>", "<D-S-p>", commands, "Search commands")
  familiar(editing_modes, "<C-S-e>", "<D-S-e>", explorer, "Toggle project explorer")
  -- Keep this requested Ctrl chord on Mac as well as Windows.
  map(editing_modes, "<C-S-g>", git_changes, "Git changed files and diffs")

  -- Very nomagic searches treat punctuation as text. Backslashes still escape.
  familiar("n", "<C-f>", "<D-f>", "/\\V", "Find text in file", { silent = false })
  familiar({ "i", "x" }, "<C-f>", "<D-f>", "<Esc>/\\V", "Find text in file", { silent = false })
  map("n", "<F3>", "nzz", "Next search match")
  map("n", "<S-F3>", "Nzz", "Previous search match")
  map("i", "<F3>", "<C-o>n<C-o>zz", "Next search match")
  map("i", "<S-F3>", "<C-o>N<C-o>zz", "Previous search match")
  map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlights")

  familiar(editing_modes, "<C-s>", "<D-s>", "<cmd>write<cr>", "Save file")
  familiar("n", "<C-z>", "<D-z>", "u", "Undo")
  familiar("x", "<C-z>", "<D-z>", "<Esc>u", "Undo")
  familiar("i", "<C-z>", "<D-z>", "<C-g>u<C-o>u", "Undo")
  familiar("n", "<C-y>", "<D-S-z>", "<C-r>", "Redo")
  familiar("x", "<C-y>", "<D-S-z>", "<Esc><C-r>", "Redo")
  familiar("i", "<C-y>", "<D-S-z>", "<C-o><C-r>", "Redo")

  familiar(editing_modes, "<C-w>", "<D-w>", M.close_tab, "Close tab (keep unsaved changes)")
  map(editing_modes, "<C-Tab>", "<cmd>tabnext<cr>", "Next tab")
  map(editing_modes, "<C-S-Tab>", "<cmd>tabprevious<cr>", "Previous tab")
  map(editing_modes, "<F8>", "<cmd>tabnext<cr>", "Next tab")
  map(editing_modes, "<S-F8>", "<cmd>tabprevious<cr>", "Previous tab")
  map("n", "<Tab>", "<cmd>tabnext<cr>", "Next tab")
  map("n", "<S-Tab>", "<cmd>tabprevious<cr>", "Previous tab")

  -- Space menus use letters reachable without AltGr on Danish keyboards.
  map("n", "<leader>e", explorer, "Toggle project explorer")
  map("n", "<leader>s", "<cmd>write<cr>", "Save file")
  map("n", "<leader>q", "<cmd>confirm quit<cr>", "Quit window")
  map("n", "<leader>qa", "<cmd>confirm qall<cr>", "Quit all")
  map("n", "<leader>x", M.close_tab, "Close tab (keep unsaved changes)")
  map("n", "<leader>b", "<cmd>b#<cr>", "Switch to alternate buffer")
  map("n", "<leader>r", function()
    vim.cmd("source $MYVIMRC")
    vim.notify("Neovim config reloaded", vim.log.levels.INFO)
  end, "Reload init.lua")
  map("n", "<leader>un", function()
    vim.wo.relativenumber = not vim.wo.relativenumber
  end, "Toggle relative numbers")

  map("n", "<leader>fp", commands, "Search commands")
  map("n", "<leader>ff", find_files, "Find project files")
  map("n", "<leader>fa", picker("find_files", { no_ignore = true }), "Find files including gitignored")
  map("n", "<leader>fg", search_project, "Search project text")
  map("n", "<leader>fb", picker("buffers"), "Find open buffers")
  map("n", "<leader>fl", picker("current_buffer_fuzzy_find"), "Find lines in this file")
  map("n", "<leader>fh", picker("help_tags"), "Search help")
  map("n", "<leader>fk", picker("keymaps"), "Search keyboard shortcuts")
  map("n", "<leader>fm", function()
    vim.lsp.buf.format({ async = false })
  end, "Format file")
  map("n", "<leader>gg", git_changes, "Git changed files and diffs")

  map("n", "<C-h>", "<C-w>h", "Move to left split")
  map("n", "<C-j>", "<C-w>j", "Move to split below")
  map("n", "<C-k>", "<C-w>k", "Move to split above")
  map("n", "<C-l>", "<C-w>l", "Move to right split")
  map("n", "<leader>wv", "<cmd>vsplit<cr>", "Split vertically")
  map("n", "<leader>wh", "<cmd>split<cr>", "Split horizontally")
  map("n", "<leader>wx", "<cmd>close<cr>", "Close split")
  map("n", "<leader>wo", "<cmd>only<cr>", "Close other splits")
  map("n", "<C-Up>", "<cmd>resize +2<cr>", "Increase split height")
  map("n", "<C-Down>", "<cmd>resize -2<cr>", "Decrease split height")
  map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", "Decrease split width")
  map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", "Increase split width")

  map("n", "<leader>tn", "<cmd>tabnew<cr>", "New tab")
  map("n", "<leader>tx", M.close_tab, "Close tab (keep unsaved changes)")
  map("n", "<leader>to", "<cmd>tabonly<cr>", "Close other tabs")
  map("n", "<leader>tt", terminal.toggle, "Toggle terminal")
  map(editing_modes, "<C-æ>", terminal.toggle, "Toggle terminal (when forwarded)")
  map("t", "<C-æ>", terminal.toggle, "Toggle terminal (when forwarded)")
  map("n", "<leader>tv", terminal.open_vertical, "Open terminal vertically")
  map("n", "<leader>ts", terminal.open_horizontal, "Open terminal horizontally")
  map("t", "<C-g>", [[<C-\><C-n>]], "Leave terminal mode")
  map("t", "<C-Space>", [[<C-\><C-n>]], "Leave terminal mode (alternative)")
end

return M
