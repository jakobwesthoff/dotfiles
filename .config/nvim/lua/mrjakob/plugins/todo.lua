return {
  "folke/todo-comments.nvim",
  -- Load when a file buffer opens so comment highlighting attaches to it
  -- immediately; the jump/search keymaps load it on demand otherwise.
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    -- Default configuration. See
    -- https://github.com/folke/todo-comments.nvim#%EF%B8%8F-configuration for
    -- details
  },
}
