-- Run from the repository: nvim --headless -u NONE -i NONE -l tests/explorer.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.swapfile = false
vim.opt.shadafile = "NONE"
vim.env.NVIM_LOG_FILE = vim.fn.tempname() .. ".log"
vim.o.columns = 120
local explorer = require("editor.explorer")
explorer.setup()

local root = vim.fn.tempname() .. " danske filer æøå"
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "på disk" }, root .. "/blåbær.txt")

local function equal(expected, actual, label)
  assert(
    vim.deep_equal(expected, actual),
    label .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual)
  )
end

local ok, err = xpcall(function()
  local cwd = vim.fn.getcwd()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "unsaved æøå" })
  explorer.toggle(root)
  equal(2, #vim.api.nvim_tabpage_list_wins(0), "Explorer opens a sidebar")
  equal("netrw", vim.bo.filetype, "Built-in explorer is active")
  equal(vim.fs.normalize(root), vim.fs.normalize(vim.b.netrw_curdir), "Directory with spaces and Danish letters")
  equal(cwd, vim.fn.getcwd(), "Explorer preserves working directory")
  equal(buf, vim.api.nvim_win_get_buf(win), "Original window still shows original buffer")
  equal(true, vim.bo[buf].modified, "Opening preserves unsaved flag")
  assert(vim.fn.search("blåbær.txt", "w") > 0, "Danish file appears in explorer")

  -- Exercise netrw's real Enter mapping, including the new-tab behavior.
  vim.api.nvim_feedkeys(vim.keycode("<CR>"), "xt", false)
  equal("blåbær.txt", vim.fn.expand("%:t"), "Enter opens the selected Danish file")
  equal(2, #vim.api.nvim_list_tabpages(), "Explorer opens files in a new tab")
  equal({ "unsaved æøå" }, vim.api.nvim_buf_get_lines(buf, 0, -1, false), "Opening a file preserves edits")
  equal(true, vim.bo[buf].modified, "Opening a file keeps the unsaved flag")
  vim.cmd.tabclose()

  explorer.toggle(root)
  equal(1, #vim.api.nvim_tabpage_list_wins(0), "Repeated toggle hides sidebar")
  equal(win, vim.api.nvim_get_current_win(), "Closing restores original focus")
  equal({ "unsaved æøå" }, vim.api.nvim_buf_get_lines(buf, 0, -1, false), "Closing preserves edited contents")
  equal(true, vim.bo[buf].modified, "Closing preserves unsaved flag")

  explorer.toggle(root)
  vim.api.nvim_set_current_win(win)
  explorer.toggle(root)
  equal(1, #vim.api.nvim_tabpage_list_wins(0), "Toggle works from the editor window")
  equal(win, vim.api.nvim_get_current_win(), "Editor focus remains intact")

  explorer.toggle(root)
  vim.api.nvim_win_close(win, false)
  explorer.toggle(root)
  equal(buf, vim.api.nvim_get_current_buf(), "Last remaining sidebar restores the original buffer")
  equal(true, vim.bo[buf].modified, "Restoring the last window preserves unsaved edits")

  -- Automatic netrw takeover must not replace the startup file picker.
  equal(0, #vim.api.nvim_get_autocmds({ group = "FileExplorer" }), "No automatic directory takeover")

  local startup = root .. "/startup.lua"
  vim.fn.writefile(
    vim.split(
      string.format(
        [[
vim.opt.rtp:prepend(%q)
local opened = false
package.loaded["telescope.builtin"] = {
  find_files = function()
    assert(vim.bo.filetype ~= "netrw", "netrw took over startup")
    assert(vim.uv.fs_realpath(vim.fn.getcwd()) == vim.uv.fs_realpath(%q), "startup did not select the directory")
    opened = true
  end,
}
require("editor.options").setup()
require("editor.explorer").setup()
vim.defer_fn(function()
  if not opened then
    vim.cmd("cquit 1")
  end
  vim.cmd("qa!")
end, 100)
]],
        cwd,
        root
      ),
      "\n"
    ),
    startup
  )
  local output = vim.fn.system({ vim.v.progpath, "--headless", "-u", startup, "-i", "NONE", root })
  equal(0, vim.v.shell_error, "Starting in a directory retains Telescope: " .. output)
end, debug.traceback)
vim.fn.delete(root, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print("PASS: netrw explorer, Danish paths, toggling, unsaved edits")
vim.cmd("qa!")
