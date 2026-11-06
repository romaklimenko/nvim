local M = {}
local sidebars = {}

function M.setup()
  vim.g.netrw_banner = 0
  vim.g.netrw_liststyle = 3
  vim.g.netrw_keepdir = 1
  -- Like the file picker, opening a file creates a tab and leaves edits intact.
  vim.g.netrw_browse_split = 3
  vim.cmd("runtime plugin/netrwPlugin.vim")
  -- Keep `nvim directory` owned by the startup Telescope picker. Explicit
  -- explorer commands still work without netrw's automatic directory takeover.
  if vim.fn.exists("#FileExplorer") == 1 then
    vim.api.nvim_clear_autocmds({ group = "FileExplorer" })
  end
end

function M.toggle(root)
  local tab = vim.api.nvim_get_current_tabpage()
  local sidebar = sidebars[tab]
  if sidebar and vim.api.nvim_win_is_valid(sidebar.win) then
    local buf = vim.api.nvim_win_get_buf(sidebar.win)
    -- Never close a file that was manually opened in the sidebar window.
    if vim.bo[buf].filetype == "netrw" then
      if #vim.api.nvim_tabpage_list_wins(tab) > 1 then
        vim.api.nvim_win_close(sidebar.win, false)
      elseif vim.api.nvim_buf_is_valid(sidebar.origin_buf) then
        vim.api.nvim_win_set_buf(sidebar.win, sidebar.origin_buf)
      else
        vim.api.nvim_win_call(sidebar.win, function()
          vim.cmd.enew()
        end)
      end
      if vim.api.nvim_win_is_valid(sidebar.origin_win) then
        vim.api.nvim_set_current_win(sidebar.origin_win)
      end
      sidebars[tab] = nil
      return
    end
  end

  root = vim.fs.normalize(root or vim.fn.getcwd())
  if vim.fn.isdirectory(root) ~= 1 then
    vim.notify("Explorer directory does not exist: " .. root, vim.log.levels.WARN)
    return
  end
  local origin_win = vim.api.nvim_get_current_win()
  local origin_buf = vim.api.nvim_get_current_buf()
  vim.cmd("topleft 30vnew")
  local win = vim.api.nvim_get_current_win()
  -- Pass paths as values, so spaces and Danish characters remain literal.
  vim.fn["netrw#Explore"](0, 0, 0, root)
  vim.wo.winfixwidth = true
  sidebars[tab] = { win = win, origin_win = origin_win, origin_buf = origin_buf }
end

return M
