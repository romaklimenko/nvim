return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      local function map(keys, action, description)
        vim.keymap.set({ "n", "x" }, keys, action, { desc = description })
      end
      local function select_matches(all, skip)
        local selection
        local already_selected
        mc.action(function(ctx)
          local cursor = ctx:mainCursor()
          already_selected = cursor:hasSelection()
          if not already_selected then
            cursor:feedkeys("viw")
          end
          selection = cursor:getVisualLines()
        end)
        if table.concat(selection, "\n") == "" then
          return
        end
        -- Ctrl+D selects the current word first, then adds the next occurrence.
        if not all and not already_selected then
          return
        end
        if skip then
          mc.matchSkipCursor(1)
        elseif all then
          mc.matchAllAddCursors()
        else
          mc.matchAddCursor(1)
        end
        -- Matching creates normal-mode cursors. Restore the selected text so
        -- one 'c' replaces every occurrence, including Danish text and phrases.
        mc.action(function(ctx)
          ctx:forEachCursor(function(cursor)
            if not cursor:hasSelection() then
              local start = cursor:getPos()
              local rows = #selection
              local last = selection[rows]
              local last_offset = #vim.fn.strcharpart(last, 0, vim.fn.strchars(last) - 1)
              -- A final empty line represents the selected newline.
              if last == "" and rows > 1 then
                rows = rows - 1
                last_offset = #selection[rows]
              end
              local last_col = (rows == 1 and start[2] or 1) + last_offset
              cursor:setMode("v")
              cursor:setVisual({ start[1], start[2] }, { start[1] + rows - 1, last_col })
            end
          end)
        end)
      end
      local function next_match()
        select_matches(false)
      end
      local function all_matches()
        select_matches(true)
      end
      map("<C-d>", next_match, "Add cursor at next match")
      map("<leader>mn", next_match, "Add cursor at next match")
      map("<C-S-l>", all_matches, "Select all matching text")
      map("<F7>", all_matches, "Select all matching text")
      map("<leader>ma", all_matches, "Select all matching text")
      map("<leader>ms", function()
        select_matches(false, true)
      end, "Skip next match")
      map("<leader>mj", function()
        mc.lineAddCursor(1)
      end, "Add cursor below")
      map("<leader>mk", function()
        mc.lineAddCursor(-1)
      end, "Add cursor above")
      map("<leader>mc", mc.clearCursors, "Clear extra cursors")
      for _, key in ipairs({ "<C-d>", "<C-S-l>", "<F7>" }) do
        vim.keymap.set("i", key, "<Esc>" .. key, { remap = true, desc = "Select matching text with cursors" })
      end
      mc.addKeymapLayer(function(set)
        set("n", "<Esc>", function()
          mc.clearCursors()
          vim.cmd.nohlsearch()
        end, { desc = "Clear extra cursors and search highlights" })
      end)
      vim.api.nvim_set_hl(0, "MultiCursorCursor", { reverse = true })
      vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
      vim.api.nvim_set_hl(0, "MultiCursorMatchPreview", { link = "Search" })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(key, action, description)
          vim.keymap.set("n", key, action, { buffer = buf, desc = description })
        end
        map("<leader>gh", gs.preview_hunk, "Preview change under cursor")
        map("<leader>gn", function()
          gs.nav_hunk("next")
        end, "Next Git change")
        map("<leader>gp", function()
          gs.nav_hunk("prev")
        end, "Previous Git change")
      end,
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
      spec = {
        { "<leader>f", group = "Find and format" },
        { "<leader>g", group = "Git changes" },
        { "<leader>m", group = "Multiple cursors", mode = { "n", "x" } },
        { "<leader>t", group = "Tabs and terminals" },
        { "<leader>u", group = "Display" },
        { "<leader>w", group = "Windows and splits" },
      },
    },
  },
}
