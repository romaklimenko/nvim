return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- LSP keybindings attached when LSP connects to buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }

          local map = vim.keymap.set
          map("n", "gd", vim.lsp.buf.definition,
            vim.tbl_extend("force", opts, { desc = "Go to definition" }))
          map("n", "gD", vim.lsp.buf.declaration,
            vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
          map("n", "gi", vim.lsp.buf.implementation,
            vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
          map("n", "gr", vim.lsp.buf.references,
            vim.tbl_extend("force", opts, { desc = "Find references" }))
          map("n", "K", vim.lsp.buf.hover,
            vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
          map("n", "<leader>rn", vim.lsp.buf.rename,
            vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, { desc = "Code action" }))
          map("n", "<leader>d", vim.diagnostic.open_float,
            vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
          map("n", "[d", vim.diagnostic.goto_prev,
            vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
          map("n", "]d", vim.diagnostic.goto_next,
            vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        end,
      })

      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })
    end,
  },
}
