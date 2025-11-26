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

  -- File browser (telescope-file-browser)
  local function open_file_browser()
    require("telescope").extensions.file_browser.file_browser({
      path = "%:p:h",
      select_buffer = true,
    })
  end
  map("n", "<leader>e", open_file_browser, vim.tbl_extend("force", opts, { desc = "Open file browser" }))

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

  -- Split management
  map("n", "<leader>sv", "<cmd>vsplit<cr>", vim.tbl_extend("force", opts, { desc = "Split vertical" }))
  map("n", "<leader>sh", "<cmd>split<cr>", vim.tbl_extend("force", opts, { desc = "Split horizontal" }))
  map("n", "<leader>sx", "<cmd>close<cr>", vim.tbl_extend("force", opts, { desc = "Close split" }))
  map("n", "<leader>so", "<cmd>only<cr>", vim.tbl_extend("force", opts, { desc = "Close other splits" }))

  -- Resize splits
  map("n", "<C-Up>", "<cmd>resize +2<cr>", vim.tbl_extend("force", opts, { desc = "Increase split height" }))
  map("n", "<C-Down>", "<cmd>resize -2<cr>", vim.tbl_extend("force", opts, { desc = "Decrease split height" }))
  map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", vim.tbl_extend("force", opts, { desc = "Decrease split width" }))
  map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", vim.tbl_extend("force", opts, { desc = "Increase split width" }))

  -- Tab management
  map("n", "<leader>tn", "<cmd>tabnew<cr>", vim.tbl_extend("force", opts, { desc = "New tab" }))
  map("n", "<leader>tx", "<cmd>tabclose<cr>", vim.tbl_extend("force", opts, { desc = "Close tab" }))
  map("n", "<leader>to", "<cmd>tabonly<cr>", vim.tbl_extend("force", opts, { desc = "Close other tabs" }))
  map("n", "<Tab>", "<cmd>tabnext<cr>", vim.tbl_extend("force", opts, { desc = "Next tab" }))
  map("n", "<S-Tab>", "<cmd>tabprevious<cr>", vim.tbl_extend("force", opts, { desc = "Previous tab" }))

  map("n", "<leader>tv", terminal.open_vertical, vim.tbl_extend("force", opts, { desc = "Open terminal (vertical)" }))
  map("n", "<leader>ts", terminal.open_horizontal,
    vim.tbl_extend("force", opts, { desc = "Open terminal (horizontal)" }))

  -- Telescope keymaps
  local telescope_ok, telescope_builtin = pcall(require, "telescope.builtin")
  if telescope_ok then
    map("n", "<leader>ff", telescope_builtin.find_files, vim.tbl_extend("force", opts, { desc = "Find files" }))
    map("n", "<leader>fg", telescope_builtin.live_grep, vim.tbl_extend("force", opts, { desc = "Live grep" }))
    map("n", "<leader>fb", telescope_builtin.buffers, vim.tbl_extend("force", opts, { desc = "Find buffers" }))
    map("n", "<leader>fh", telescope_builtin.help_tags, vim.tbl_extend("force", opts, { desc = "Help tags" }))
  end

  -- Terminal-mode escapes easier to reach on Danish layouts than <C-\><C-n>.
  map("t", "<C-g>", [[<C-\><C-n>]], vim.tbl_extend("force", opts, { desc = "Leave terminal mode" }))
  map("t", "<C-Space>", [[<C-\><C-n>]], vim.tbl_extend("force", opts, { desc = "Leave terminal mode (alt)" }))
end

return M
