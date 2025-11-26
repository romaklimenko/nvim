return {
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- Load theme before other plugins
    config = function()
      require("onedark").setup({
        style = "deep",
      })
      require("onedark").load()
    end,
  },
}
