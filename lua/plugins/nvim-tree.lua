return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 35,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
        -- Auto-open when last buffer is closed
        update_focused_file = {
          enable = true,
          update_root = false,
        },
      })

      -- Auto-open nvim-tree when opening a directory or when last buffer is closed
      local function open_nvim_tree(data)
        -- Check if buffer is a directory
        local directory = vim.fn.isdirectory(data.file) == 1

        if directory then
          vim.cmd.cd(data.file)
          require("nvim-tree.api").tree.open()
          return
        end
      end

      vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

      -- Open nvim-tree when last buffer is closed
      vim.api.nvim_create_autocmd("BufDelete", {
        callback = function()
          vim.schedule(function()
            local buffers = vim.fn.getbufinfo({ buflisted = 1 })
            local real_buffers = vim.tbl_filter(function(buf)
              return buf.name ~= "" and vim.fn.bufexists(buf.bufnr) == 1
            end, buffers)

            if #real_buffers == 0 then
              require("nvim-tree.api").tree.open()
            end
          end)
        end,
      })
    end,
  },
}
