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
              checkOnSave = {
                command = "clippy",
              },
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
      }

      require("mason-lspconfig").setup({
        -- LSP servers to auto-install
        ensure_installed = {
          "pyright", -- Python
          "rust_analyzer", -- Rust
        },
        automatic_installation = true,
        -- Setup handlers for each server
        handlers = {
          -- Default handler for all servers
          function(server_name)
            local config = servers[server_name] or {}
            require("lspconfig")[server_name].setup(config)
          end,
        },
      })
    end,
  },
}
