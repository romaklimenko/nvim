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

  -- Open telescope when starting in a directory
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function(data)
      local is_directory = vim.fn.isdirectory(data.file) == 1
      if is_directory then
        vim.cmd.cd(data.file)
        -- Mark the startup tab for cleanup
        vim.g.startup_empty_tab = vim.api.nvim_get_current_tabpage()
        vim.defer_fn(function()
          require("telescope.builtin").find_files()
        end, 0)
      end
    end,
  })
end

return M
