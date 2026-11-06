vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("plugins").setup()
require("editor.options").setup()
require("editor.explorer").setup()
require("editor.keymaps").setup()
