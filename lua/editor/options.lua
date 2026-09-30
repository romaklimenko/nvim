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
  o.signcolumn = "yes"
  o.showtabline = 2
  o.scrolloff = 5
  o.ignorecase = true
  o.smartcase = true
  o.incsearch = true
  o.hlsearch = true
  o.undofile = true

  -- Open telescope when starting in a directory
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("EditorStartup", { clear = true }),
    callback = function(data)
      local is_directory = vim.fn.isdirectory(data.file) == 1
      if is_directory then
        vim.cmd.cd(data.file)
        vim.defer_fn(function()
          require("telescope.builtin").find_files()
        end, 0)
      end
    end,
  })
end

return M
