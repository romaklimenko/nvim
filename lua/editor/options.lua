local M = {}

function M.setup()
  local o = vim.opt
  o.number = true
  o.relativenumber = true
  o.expandtab = true
  o.shiftwidth = 2
  o.tabstop = 2
  o.termguicolors = true
  o.splitright = true
  o.splitbelow = true
end

return M
