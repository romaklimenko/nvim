-- Run from the repository: nvim --headless -u NONE -i NONE -l tests/terminal.lua
-- No plugins or user configuration are loaded.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.swapfile = false
vim.opt.shadafile = "NONE"
vim.opt.hidden = true
local terminal = require("editor.terminal")
local jobs = {}

local function equal(expected, actual, label)
  assert(
    vim.deep_equal(expected, actual),
    label .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual)
  )
end

local function test_shell_selection()
  local original = { has = vim.fn.has, executable = vim.fn.executable, termopen = vim.fn.termopen }
  local saved_shell = vim.env.SHELL
  local cases = {
    { os = "win32", available = { pwsh = true }, expected = { "pwsh", "-NoLogo" } },
    { os = "win32", available = { powershell = true }, expected = { "powershell", "-NoLogo" } },
    { os = "win32", available = {}, expected = { "cmd.exe" } },
    {
      os = "macunix",
      shell = "/custom/shell",
      available = { ["/custom/shell"] = true },
      expected = { "/custom/shell" },
    },
    { os = "macunix", shell = "/missing/shell", available = { zsh = true, bash = true }, expected = { "zsh" } },
    { os = "macunix", available = { bash = true }, expected = { "bash" } },
    { os = "unix", available = { zsh = true, bash = true }, expected = { "bash" } },
    { os = "unix", available = {}, expected = { "sh" } },
  }
  local ok, err = xpcall(function()
    for _, case in ipairs(cases) do
      vim.fn.has = function(name)
        return name == case.os and 1 or 0
      end
      vim.fn.executable = function(name)
        return case.available[name] and 1 or 0
      end
      vim.fn.termopen = function(cmd)
        equal(case.expected, cmd, "Shell selection for " .. case.os)
        return 1
      end
      vim.env.SHELL = case.shell
      terminal.open_horizontal()
      vim.cmd("stopinsert")
      vim.cmd("close")
    end
  end, debug.traceback)
  for name, fn in pairs(original) do
    vim.fn[name] = fn
  end
  vim.env.SHELL = saved_shell
  assert(ok, err)
end

local function shell_output(buf, text)
  return vim.wait(3000, function()
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):find(text, 1, true) ~= nil
  end, 10)
end

local function test_toggle()
  -- Use a plain shell without the user's interactive zsh configuration on Unix.
  if vim.fn.has("win32") == 0 then
    vim.env.SHELL = vim.fn.exepath("sh")
    vim.env.ENV = nil
  end
  local file = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(file, 0, -1, false, { "unsaved Danish text: æøå" })
  terminal.toggle()
  local buf = vim.api.nvim_get_current_buf()
  local job = vim.b[buf].terminal_job_id
  table.insert(jobs, job)
  equal("terminal", vim.bo[buf].buftype, "Toggle opens a real terminal")
  equal(2, #vim.api.nvim_tabpage_list_wins(0), "Terminal opens beside unsaved file")
  terminal.toggle()
  equal(file, vim.api.nvim_get_current_buf(), "Hide returns to file")
  equal(true, vim.bo[file].modified, "Unsaved file stays modified")
  equal(
    { "unsaved Danish text: æøå" },
    vim.api.nvim_buf_get_lines(file, 0, -1, false),
    "Unsaved file content survives"
  )
  terminal.toggle()
  equal(buf, vim.api.nvim_get_current_buf(), "Show reuses terminal buffer")
  equal(job, vim.b[buf].terminal_job_id, "Show reuses running shell")
  vim.fn.chansend(job, "echo terminal_toggle_alive\n")
  assert(shell_output(buf, "terminal_toggle_alive"), "Reused shell responds")

  local replacement = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(replacement, 0, -1, false, { "another unsaved file" })
  local replacement_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(0, replacement)
  terminal.toggle()
  equal(replacement, vim.api.nvim_win_get_buf(replacement_window), "Toggle does not close repurposed window")
  equal(true, vim.bo[replacement].modified, "Repurposed window keeps unsaved content")
  equal(buf, vim.api.nvim_get_current_buf(), "Hidden terminal opens again")

  vim.cmd("only")
  terminal.toggle()
  equal(1, #vim.api.nvim_tabpage_list_wins(0), "Last terminal window can be hidden")
  equal("", vim.bo.buftype, "Last-window hide shows a normal buffer")
  equal(-1, vim.fn.jobwait({ job }, 0)[1], "Last-window hide keeps shell alive")
  terminal.toggle()
  equal(buf, vim.api.nvim_get_current_buf(), "Last-window terminal can be restored")

  vim.cmd("tabnew")
  local other_tab = vim.api.nvim_get_current_tabpage()
  terminal.toggle()
  equal(other_tab, vim.api.nvim_get_current_tabpage(), "Toggle stays in current tab")
  equal(buf, vim.api.nvim_get_current_buf(), "Terminal can be shown in another tab")
  terminal.toggle()
  equal(1, #vim.api.nvim_tabpage_list_wins(0), "Hide only removes current-tab terminal")
  vim.cmd("tabprevious")
  equal(buf, vim.api.nvim_get_current_buf(), "Other-tab terminal window survives")

  vim.fn.chansend(job, "exit\n")
  assert(
    vim.wait(3000, function()
      return vim.fn.jobwait({ job }, 0)[1] ~= -1
    end, 10),
    "Shell exited"
  )
  terminal.toggle()
  terminal.toggle()
  local restarted = vim.b.terminal_job_id
  table.insert(jobs, restarted)
  assert(restarted and restarted ~= job, "Exited shell is restarted")
  equal(-1, vim.fn.jobwait({ restarted }, 0)[1], "Restarted shell is running")
end

local ok, err = xpcall(function()
  test_shell_selection()
  test_toggle()
end, debug.traceback)
for _, job in ipairs(jobs) do
  pcall(vim.fn.jobstop, job)
end
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print("PASS: shell selection, terminal reuse, unsaved files, last window, tabs, exited shell")
vim.cmd("qa!")
