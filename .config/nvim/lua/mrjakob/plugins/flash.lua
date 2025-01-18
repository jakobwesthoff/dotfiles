return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  config = function()
    local U = require("mrjakob.util")
    U.newColorWithBase("FlashLabel", "Search", { bg = U.getColor("Yellow", "fg") })
    require("flash").setup({
      modes = {
        search = {
          enabled = false,
        },
      },
    })
  end,
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Fla[s]h" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Tree[S]itter" },
    -- { "r", mode = {"o", "n"}, function() require("flash").remote() end, desc = "[R]emote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitte[R] Search" },
  },
}
