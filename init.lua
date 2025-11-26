vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw early (before plugins load)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("plugins").setup()
require("editor.options").setup()
require("editor.keymaps").setup()
