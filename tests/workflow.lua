-- Run from the repository: nvim --headless -u NONE -i NONE -l tests/workflow.lua
-- NVIM_TEST_PLUGINS can point to an existing lazy.nvim plugin directory.
local repo = vim.fn.getcwd()
local plugins = vim.env.NVIM_TEST_PLUGINS or (vim.fn.stdpath("data") .. "/lazy")
-- A child receives real input and idle events, including multicursor's SafeState.
local child = vim.fn.jobstart({ vim.v.progpath, "--embed", "--headless", "-u", "NONE", "-i", "NONE" }, { rpc = true })
assert(child > 0, "Could not start test Neovim")

local function lua(code, args)
  return vim.rpcrequest(child, "nvim_exec_lua", code, args or {})
end

local function equal(expected, actual, label)
  assert(vim.deep_equal(expected, actual), label .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function keys(text)
  vim.rpcrequest(child, "nvim_input", text)
  vim.wait(50)
end

local function line()
  return vim.rpcrequest(child, "nvim_get_current_line")
end

local function buffer(lines)
  keys("<Esc><Esc>")
  lua([[
    require("multicursor-nvim").clearCursors()
    vim.cmd.enew({ bang = true })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, ...)
    vim.bo.modified = false
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  ]], { lines })
end

local function test_editing()
  buffer({ "alpha alpha alpha" })
  keys("<C-d>")
  equal("v", lua("return vim.fn.mode()"), "Ctrl+D selects current word")
  keys("<C-d>")
  keys("cbravo<Esc>")
  equal("bravo bravo alpha", line(), "Ctrl+D replaces two matches")
  keys("<Esc><C-z>")
  equal("alpha alpha alpha", line(), "Undo multicursor edit")
  keys("<C-y>")
  equal("bravo bravo alpha", line(), "Redo multicursor edit")

  buffer({ "blåbær blåbær blåbær" })
  keys("<F7>")
  equal(3, lua("return require('multicursor-nvim').numCursors()"), "F7 creates three cursors")
  equal("v", lua("return vim.fn.mode()"), "F7 selects text")
  keys("cgrød<Esc>")
  keys("<Esc>")
  equal("grød grød grød", line(), "Select all Danish matches")

  buffer({ "foo.bar fooXbar foo.bar" })
  keys("v6l<C-d>")
  keys("cvalgt<Esc>")
  keys("<Esc>")
  equal("valgt fooXbar valgt", line(), "Multiselect literal punctuation")

  buffer({ "one one one" })
  keys("<C-d>")
  keys("<C-d>")
  keys(" ms")
  keys("cchosen<Esc>")
  keys("<Esc>")
  equal("chosen one chosen", line(), "Skip match preserves selections")

  buffer({ "first", "last", "first", "last" })
  keys("vje")
  keys("<F7>")
  keys("creplaced<Esc>")
  keys("<Esc>")
  equal({ "replaced", "replaced" }, lua("return vim.api.nvim_buf_get_lines(0, 0, -1, false)"), "Select multiline phrases")

  buffer({ "first", "last", "gap", "first", "last", "tail" })
  keys("vj$")
  keys("creplaced<Esc>")
  equal({ "replacedgap", "first", "last", "tail" }, lua("return vim.api.nvim_buf_get_lines(0, 0, -1, false)"), "Native replacement includes selected newline")
  buffer({ "first", "last", "gap", "first", "last", "tail" })
  keys("vj$")
  keys("<F7>")
  keys("creplaced<Esc>")
  keys("<Esc>")
  equal({ "replacedgap", "replacedtail" }, lua("return vim.api.nvim_buf_get_lines(0, 0, -1, false)"), "Selections ending at line breaks")

  buffer({ "match match" })
  keys("a")
  keys("<C-S-l>")
  keys("cnew<Esc>")
  keys("<Esc>")
  equal("new new", line(), "Select all from insert mode")

  buffer({ "start" })
  keys("A end")
  keys("<C-z>")
  keys("<Esc>")
  equal("start", line(), "Undo in insert mode")
  keys("<C-y>")
  equal("start end", line(), "Redo insert edit")

  buffer({ "fooXbar", "foo.bar", "foo.bar" })
  keys("<C-f>foo.bar<CR>")
  equal(2, lua("return vim.fn.line('.')"), "Ctrl+F searches literal punctuation")
  keys("<F3>")
  equal(3, lua("return vim.fn.line('.')"), "F3 next match")
  keys("<S-F3>")
  equal(2, lua("return vim.fn.line('.')"), "Shift+F3 previous match")
end

local function test_tabs()
  buffer({ "saved" })
  local saved = lua("return vim.api.nvim_get_current_tabpage()")
  lua("vim.cmd.tabnew()")
  local unsaved = lua("return vim.api.nvim_get_current_tabpage()")
  keys("iunsaved<Esc>")
  keys("<C-w>")
  equal(unsaved, lua("return vim.api.nvim_get_current_tabpage()"), "Unsaved tab stays open")
  equal(2, lua("return #vim.api.nvim_list_tabpages()"), "Unsaved tab is not closed")
  keys("<F8>")
  equal(saved, lua("return vim.api.nvim_get_current_tabpage()"), "F8 next tab")
  keys("<S-F8>")
  equal(unsaved, lua("return vim.api.nvim_get_current_tabpage()"), "Shift+F8 previous tab")
  keys("<C-Tab>")
  equal(saved, lua("return vim.api.nvim_get_current_tabpage()"), "Ctrl+Tab when forwarded")
  keys("<S-Tab>")
  equal(unsaved, lua("return vim.api.nvim_get_current_tabpage()"), "Shift+Tab fallback")
  lua("vim.bo.modified = false")
  keys("<C-w>")
  equal(saved, lua("return vim.api.nvim_get_current_tabpage()"), "Ctrl+W closes saved tab")
  keys("<C-w>")
  equal(1, lua("return #vim.api.nvim_list_tabpages()"), "Closing last tab keeps Neovim open")
  equal("", line(), "Last tab becomes empty")
  keys("iunsaved split<Esc>")
  lua("vim.cmd.vnew()")
  keys("<C-w>")
  equal(2, lua("return #vim.api.nvim_tabpage_list_wins(0)"), "Unsaved sibling split prevents tab closing")
  lua("vim.cmd('only!'); vim.cmd.enew({ bang = true })")
end

local function picker_ready()
  assert(vim.wait(3000, function()
    return lua("return require('telescope.actions.state').get_selected_entry() ~= nil")
  end, 20), "Picker did not load")
end

local function test_telescope()
  local function select_file(mode, expected_tabs)
    lua([[
      require("telescope.builtin").find_files({
        cwd = ...,
        find_command = { "git", "ls-files", "README.md" },
        initial_mode = select(2, ...),
        previewer = false,
      })
    ]], { repo, mode })
    picker_ready()
    keys("<CR>")
    equal(expected_tabs, lua("return #vim.api.nvim_list_tabpages()"), "Telescope Enter tab count")
    equal("README.md", lua("return vim.fn.expand('%:t')"), "Telescope Enter opens selected file")
  end
  select_file("i", 1)
  select_file("n", 2)
  local count = lua("return #vim.api.nvim_list_tabpages()")
  lua([[
    require("telescope.builtin").current_buffer_fuzzy_find({
      default_text = "Overview", initial_mode = "n", previewer = false,
    })
  ]])
  picker_ready()
  keys("<CR>")
  equal(count, lua("return #vim.api.nvim_list_tabpages()"), "Current-file search stays in its tab")
end

local ok, err = xpcall(function()
  lua([[
    local repo, plugins = ...
    vim.opt.rtp:prepend(repo)
    for _, name in ipairs({ "plenary.nvim", "telescope.nvim", "multicursor.nvim" }) do
      vim.opt.rtp:append(plugins .. "/" .. name)
    end
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.opt.swapfile = false
    vim.opt.shadafile = "NONE"
    vim.o.lines = 40
    vim.o.columns = 120
    require("editor.options").setup()
    require("plugins.telescope")[1].config()
    require("plugins.editing")[1].config()
    require("editor.keymaps").setup()
    vim.o.undofile = false
  ]], { repo, plugins })
  test_editing()
  test_tabs()
  test_telescope()
  equal(vim.fs.normalize(repo), lua("return vim.fs.normalize(require('editor.keymaps').project_root())"), "Submodule project root")
end, debug.traceback)
if not ok then
  io.stderr:write(lua("return vim.api.nvim_exec2('messages', { output = true }).output") .. "\n")
  vim.fn.jobstop(child)
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
vim.fn.jobstop(child)
print("PASS: editing, Danish multicursors, undo, search, safe tabs, Telescope")
vim.cmd("qa!")
