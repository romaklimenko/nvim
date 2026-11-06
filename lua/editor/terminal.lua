local M = {}
local toggle_buffer

local function detect_shell()
  if vim.fn.has("win32") == 1 then
    for _, shell in ipairs({ "pwsh", "powershell" }) do
      if vim.fn.executable(shell) == 1 then
        return { shell, "-NoLogo" }, "PowerShell"
      end
    end
    return { "cmd.exe" }, "Command Prompt"
  end

  local shell = vim.env.SHELL
  if shell and shell ~= "" and vim.fn.executable(shell) == 1 then
    return { shell }, shell
  end

  if vim.fn.has("macunix") == 1 and vim.fn.executable("zsh") == 1 then
    return { "zsh" }, "zsh"
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
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = "terminal"
  vim.fn.termopen(cmd)
  vim.b[buf].terminal_shell_label = label
  if opts.after then
    opts.after()
  end
  vim.cmd("startinsert")
  return buf
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

function M.toggle()
  -- Find the buffer, not a remembered window: a user may have replaced that
  -- window with an unsaved file since the last toggle.
  if toggle_buffer and vim.api.nvim_buf_is_valid(toggle_buffer) then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(win) == toggle_buffer then
        vim.cmd("stopinsert")
        if not pcall(vim.api.nvim_win_hide, win) then
          -- Neovim cannot hide its last ordinary window. Keep the shell alive
          -- and show an empty buffer instead.
          vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
        end
        return
      end
    end
    local job = vim.b[toggle_buffer].terminal_job_id
    if job and vim.fn.jobwait({ job }, 0)[1] == -1 then
      vim.cmd("botright split")
      vim.api.nvim_win_set_buf(0, toggle_buffer)
      vim.cmd("resize 12")
      vim.cmd("startinsert")
      return
    end
  end
  toggle_buffer = spawn({
    open = function()
      vim.cmd("botright split")
    end,
    after = function()
      vim.cmd("resize 12")
    end,
  })
end

return M
