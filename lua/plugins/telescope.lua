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

      -- Custom tab select that cleans up empty starting buffer
      local function select_tab_and_cleanup(prompt_bufnr)
        -- Store current tab before opening new one
        local current_tab = vim.api.nvim_get_current_tabpage()
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(current_buf)
        local buf_lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
        local is_empty = buf_name == "" and #buf_lines == 1 and buf_lines[1] == ""

        -- Open in new tab
        actions.select_tab(prompt_bufnr)

        -- If the original buffer was empty, close its tab
        if is_empty and vim.api.nvim_tabpage_is_valid(current_tab) then
          vim.defer_fn(function()
            local current_new_tab = vim.api.nvim_get_current_tabpage()
            if current_tab ~= current_new_tab then
              vim.api.nvim_set_current_tabpage(current_tab)
              vim.cmd("tabclose")
            end
          end, 50)
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
