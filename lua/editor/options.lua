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

  -- Open telescope-file-browser when opening a directory
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function(data)
      local is_directory = vim.fn.isdirectory(data.file) == 1
      if is_directory then
        vim.cmd.cd(data.file)
        vim.defer_fn(function()
          require("telescope").extensions.file_browser.file_browser({
            cwd = data.file,
          })
        end, 0)
      end
    end,
  })
end

return M
