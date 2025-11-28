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
      local action_state = require("telescope.actions.state")

      -- Custom tab select that cleans up empty startup tab
      local function select_tab_and_cleanup(prompt_bufnr)
        -- Open in new tab first
        actions.select_tab(prompt_bufnr)

        -- Clean up the startup empty tab if it exists
        if vim.g.startup_empty_tab then
          vim.defer_fn(function()
            local startup_tab = vim.g.startup_empty_tab
            if vim.api.nvim_tabpage_is_valid(startup_tab) then
              local current_tab = vim.api.nvim_get_current_tabpage()
              if startup_tab ~= current_tab then
                vim.api.nvim_set_current_tabpage(startup_tab)
                vim.cmd("tabclose")
                vim.g.startup_empty_tab = nil
              end
            end
          end, 100)
        end
      end

      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-t>"] = select_tab_and_cleanup,
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
            hidden = false,
            no_ignore = false,
          },
        },
      })
    end,
  },
}
