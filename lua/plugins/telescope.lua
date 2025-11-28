return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-t>"] = actions.select_tab,
            },
          },
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
          file_ignore_patterns = { "^.git/" },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
          },
        },
      })
    end,
  },
}
