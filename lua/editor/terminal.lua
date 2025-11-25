local M = {}

local function detect_shell()
  if vim.fn.has("win32") == 1 then
    if vim.fn.executable("pwsh") == 1 then
      return { "pwsh", "-NoLogo" }, "PowerShell"
    end
    return { "powershell", "-NoLogo" }, "PowerShell"
  end

  local shell = vim.env.SHELL
  if shell and #shell > 0 then
    return { shell }, shell
  end

  if vim.fn.executable("bash") == 1 then
    return { "bash" }, "bash"
  end

  return { "sh" }, "sh"
end

local function spawn(opts)
  local cmd, label = detect_shell()
  if opts.open then
    opts.open()
  end
  vim.cmd("enew")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = "terminal"
  vim.fn.termopen(cmd)
  vim.b[buf].terminal_shell_label = label
  if opts.after then
    opts.after()
  end
  vim.cmd("startinsert")
end

function M.open_vertical()
  spawn({
    open = function()
      vim.cmd("vsplit")
    end,
  })
end

function M.open_horizontal()
  spawn({
    open = function()
      vim.cmd("split")
    end,
    after = function()
      vim.cmd("resize 12")
    end,
  })
end

function M.open_tab()
  spawn({
    open = function()
      vim.cmd("tabnew")
    end,
  })
end

return M
