return {
  "folke/zen-mode.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  keys = {
    {
      "<leader>z",
      function()
        require("zen-mode").toggle()
      end,
      mode = { "n" },
      desc = "Toggle [Z]en Mode",
    },
  },
  opts = {
    window = {
      width = 100,
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorcolumn = false,
      },
    },
    on_open = function()
      ---@diagnostic disable-next-line: undefined-global
      Snacks.indent.disable()
    end,
    on_close = function()
      ---@diagnostic disable-next-line: undefined-global
      Snacks.indent.enable()
    end,
  },
}
