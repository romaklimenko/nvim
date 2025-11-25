local M = {}

function M.setup()
  -- Bootstrap lazy.nvim
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Load plugins
  require("lazy").setup({
    { import = "plugins.telescope" },
    { import = "plugins.nvim-tree" },
    { import = "plugins.mason" },
    { import = "plugins.lsp" },
  }, {
    ui = {
      border = "rounded",
    },
  })
end

return M
