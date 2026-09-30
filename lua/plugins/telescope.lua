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

      local function select_file_tab(prompt_bufnr)
        if not action_state.get_selected_entry() then
          return
        end
        local picker = action_state.get_current_picker(prompt_bufnr)
        local win = picker.original_win_id
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        local normal_windows = vim.tbl_filter(function(window)
          return vim.api.nvim_win_get_config(window).relative == ""
        end, vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win)))
        local empty = #normal_windows == 1
          and not vim.bo[buf].modified
          and vim.bo[buf].buftype == ""
          and (name == "" or vim.fn.isdirectory(name) == 1)
          and vim.api.nvim_buf_line_count(buf) == 1
          and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""

        -- Reuse an empty tab. Never close another tab after a delayed callback.
        if empty then
          actions.select_default(prompt_bufnr)
        else
          actions.select_tab(prompt_bufnr)
        end
      end

      local file_mappings = {
        i = { ["<CR>"] = select_file_tab, ["<C-t>"] = select_file_tab, ["<C-o>"] = actions.select_default },
        n = { ["<CR>"] = select_file_tab, ["<C-t>"] = select_file_tab, ["<C-o>"] = actions.select_default },
      }
      local pickers = {}
      -- Leave command, keymap, help and current-buffer pickers' actions intact.
      for _, name in ipairs({ "find_files", "git_files", "oldfiles", "buffers", "live_grep", "grep_string", "git_status" }) do
        pickers[name] = { mappings = vim.deepcopy(file_mappings) }
      end
      pickers.find_files.hidden = false
      pickers.find_files.no_ignore = false

      require("telescope").setup({
        defaults = {
          mappings = {
            i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" },
          },
          layout_config = { horizontal = { preview_width = 0.55 } },
          file_ignore_patterns = { "^%.git/", "^%.git\\" },
        },
        pickers = pickers,
      })
    end,
  },
}
