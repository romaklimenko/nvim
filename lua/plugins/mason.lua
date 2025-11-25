return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        -- LSP servers to auto-install
        ensure_installed = {
          "pyright", -- Python
          "rust_analyzer", -- Rust
          "ts_ls", -- TypeScript/JavaScript
          "gopls", -- Go
        },
        automatic_installation = true,
      })
    end,
  },
}
