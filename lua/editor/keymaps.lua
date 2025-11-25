local M = {}

local terminal = require("editor.terminal")

local function toggle_relative_numbers()
  vim.opt.relativenumber = not vim.wo.relativenumber
end

local function reload_init()
  vim.cmd("source $MYVIMRC")
  vim.notify("Neovim config reloaded", vim.log.levels.INFO)
end

local function format_buffer()
  local ok = pcall(vim.lsp.buf.format, { async = false })
  if not ok then
    vim.notify("No LSP formatter attached", vim.log.levels.WARN)
  end
end

function M.setup()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  map("n", "<leader>e", function()
    vim.cmd("Ex")
  end, vim.tbl_extend("force", opts, { desc = "Open file explorer" }))

  map("n", "<leader>s", "<cmd>w<cr>", vim.tbl_extend("force", opts, { desc = "Save buffer" }))
  map("n", "<leader>q", "<cmd>q<cr>", vim.tbl_extend("force", opts, { desc = "Quit window" }))
  map("n", "<leader>f", format_buffer, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
  map("n", "<leader>r", reload_init, vim.tbl_extend("force", opts, { desc = "Reload init.lua" }))
  map("n", "<leader>t", toggle_relative_numbers, vim.tbl_extend("force", opts, { desc = "Toggle relative numbers" }))
  map("n", "<leader>b", "<cmd>b#<cr>", vim.tbl_extend("force", opts, { desc = "Switch to alternate buffer" }))

  map("n", "<C-h>", "<C-w>h", vim.tbl_extend("force", opts, { desc = "Move to left split" }))
  map("n", "<C-j>", "<C-w>j", vim.tbl_extend("force", opts, { desc = "Move to split below" }))
  map("n", "<C-k>", "<C-w>k", vim.tbl_extend("force", opts, { desc = "Move to split above" }))
  map("n", "<C-l>", "<C-w>l", vim.tbl_extend("force", opts, { desc = "Move to right split" }))

  map("n", "<leader>tv", terminal.open_vertical, vim.tbl_extend("force", opts, { desc = "Open terminal (vertical)" }))
  map("n", "<leader>ts", terminal.open_horizontal, vim.tbl_extend("force", opts, { desc = "Open terminal (horizontal)" }))

  -- Terminal-mode escapes easier to reach on Danish layouts than <C-\><C-n>.
  map("t", "<C-g>", [[<C-\><C-n>]], vim.tbl_extend("force", opts, { desc = "Leave terminal mode" }))
  map("t", "<C-Space>", [[<C-\><C-n>]], vim.tbl_extend("force", opts, { desc = "Leave terminal mode (alt)" }))
end

return M
