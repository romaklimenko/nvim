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
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- Server-specific configurations
      local servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
              },
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
      }

      -- mason-lspconfig v2 enables native Neovim LSP configurations.
      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end
      require("mason-lspconfig").setup({
        -- LSP servers to auto-install
        ensure_installed = {
          "pyright", -- Python
          "rust_analyzer", -- Rust
        },
        automatic_enable = { "pyright", "rust_analyzer" },
      })
    end,
  },
}
