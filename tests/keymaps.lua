-- Run from the repository: nvim --headless -u NONE -i NONE -l tests/keymaps.lua
-- Check platform defaults without plugins, user files, or shell processes.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.shadafile = "NONE"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
local calls = {}
local function record(name)
  return function(arg)
    calls[name] = { arg = arg }
  end
end
package.loaded["editor.terminal"] = {
  toggle = record("terminal"),
  open_vertical = record("vertical"),
  open_horizontal = record("horizontal"),
}
package.loaded["editor.explorer"] = { toggle = record("explorer") }
package.loaded["telescope.builtin"] = setmetatable({}, {
  __index = function(_, name)
    return record(name)
  end,
})
local cursor = {
  hasSelection = function()
    return true
  end,
  getVisualLines = function()
    return { "blåbær" }
  end,
}
package.loaded["multicursor-nvim"] = {
  setup = function() end,
  addKeymapLayer = function() end,
  clearCursors = record("clear_cursors"),
  matchAddCursor = record("next_match"),
  matchAllAddCursors = record("all_matches"),
  matchSkipCursor = record("skip_match"),
  lineAddCursor = record("line_cursor"),
  action = function(fn)
    fn({
      mainCursor = function()
        return cursor
      end,
      forEachCursor = function(_, callback)
        callback(cursor)
      end,
    })
  end,
}

local function equal(expected, actual, label)
  assert(
    vim.deep_equal(expected, actual),
    label .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual)
  )
end

local function mapping(key, mode)
  return vim.fn.maparg(key, mode or "n", false, true)
end

local function invoke(key, action, mode)
  calls[action] = nil
  local map = mapping(key, mode)
  assert(type(map.callback) == "function", key .. " has an executable callback")
  map.callback()
  assert(calls[action], key .. " invokes " .. action)
  return calls[action].arg
end

local has = vim.fn.has
local cases = {
  { os = "mac", ctrl = false },
  { os = "win32", ctrl = true },
  { os = "unix", ctrl = true },
  { os = "mac", style = "vscode", ctrl = true },
  { os = "win32", style = "native", ctrl = false },
  { os = "mac", env = "vscode", ctrl = true },
  { os = "win32", env = "native", ctrl = false },
  { os = "mac", style = "native", env = "vscode", ctrl = false },
  { os = "win32", style = "vscode", env = "native", ctrl = true },
}

local ok, err = xpcall(function()
  for _, case in ipairs(cases) do
    for _, mode in ipairs({ "n", "i", "x", "t" }) do
      vim.cmd(mode .. "mapclear")
    end
    vim.fn.has = function(name)
      if name == "mac" or name == "macunix" or name == "win32" then
        return (name == case.os or (name == "macunix" and case.os == "mac")) and 1 or 0
      end
      return has(name)
    end
    vim.g.editor_keymap_style = case.style
    vim.env.NVIM_KEYMAP_STYLE = case.env
    require("plugins.editing")[1].config()
    require("editor.keymaps").setup()
    local label = vim.inspect(case)
    for _, mode in ipairs({ "n", "i", "x" }) do
      for _, key in ipairs({ "<C-d>", "<C-f>", "<C-p>", "<C-w>", "<C-z>", "<C-y>" }) do
        equal(case.ctrl, next(mapping(key, mode)) ~= nil, label .. " " .. mode .. " " .. key)
      end
      for _, key in ipairs({ "<D-p>", "<D-S-p>", "<D-S-f>", "<D-d>", "<D-S-l>", "<D-f>", "<D-S-e>" }) do
        assert(next(mapping(key, mode)), label .. " Command alias " .. mode .. " " .. key)
      end
    end
    equal("/\\V", mapping("<D-f>").rhs, "Cmd+F starts a literal search")
    equal("<Esc>/\\V", mapping("<D-f>", "i").rhs, "Cmd+F leaves insertion before searching")
    equal(0, mapping("<D-f>").silent, "Search prompt stays visible")
    equal("u", mapping("<D-z>").rhs, "Cmd+Z uses native undo")
    equal("<C-r>", mapping("<D-S-z>").rhs, "Cmd+Shift+Z uses native redo")
    equal("<cmd>tabnext<cr>", mapping("<C-Tab>").rhs, "Ctrl+Tab always changes tab")
    equal("<cmd>tabprevious<cr>", mapping("<C-S-Tab>").rhs, "Ctrl+Shift+Tab changes previous tab")

    local root = require("editor.keymaps").project_root()
    equal(root, invoke("<D-p>", "find_files").cwd, "Cmd+P uses project root")
    equal(root, invoke("<D-S-p>", "commands").cwd, "Cmd+Shift+P opens commands")
    equal({ "--fixed-strings" }, invoke("<D-S-f>", "live_grep").additional_args, "Project search stays literal")
    equal(root, invoke("<C-S-g>", "git_status").cwd, "Ctrl+Shift+G works in either style")
    equal(root, invoke("<D-S-e>", "explorer"), "Cmd+Shift+E opens project explorer")
    invoke("<D-d>", "next_match")
    invoke("<D-S-l>", "all_matches")
    invoke("<C-æ>", "terminal")
    invoke("<C-æ>", "terminal", "t")
    invoke("<leader>tt", "terminal")
    invoke("<leader>fp", "commands")
    invoke("<leader>e", "explorer")
    invoke("<leader>mn", "next_match")
    invoke("<leader>ma", "all_matches")
  end
end, debug.traceback)
vim.fn.has = has
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print("PASS: Mac/Windows/Linux defaults, style overrides, Command actions, Danish terminal toggle")
vim.cmd("qa!")
