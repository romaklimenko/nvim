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

      -- Helper to close empty unnamed buffers after opening a file
      local function close_empty_unnamed_buffers()
        local buffers = vim.api.nvim_list_bufs()
        for _, buf in ipairs(buffers) do
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local is_empty = #lines == 1 and lines[1] == ""
            if name == "" and is_empty and not vim.bo[buf].modified then
              vim.api.nvim_buf_delete(buf, { force = false })
            end
          end
        end
      end

      -- Custom select action that cleans up empty buffers
      local function select_and_cleanup(prompt_bufnr, mode)
        local select_fn = mode == "tab" and actions.select_tab or actions.select_default
        select_fn(prompt_bufnr)
        vim.defer_fn(close_empty_unnamed_buffers, 10)
      end

      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-t>"] = function(prompt_bufnr)
                select_and_cleanup(prompt_bufnr, "tab")
              end,
              ["<CR>"] = function(prompt_bufnr)
                select_and_cleanup(prompt_bufnr, "default")
              end,
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
