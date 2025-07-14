return {
  "obsidian-nvim/obsidian.nvim",
  lazy = false,
  ft = "markdown",
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre /Users/jakob/Library/Mobile Documents/iCloud~md~obsidian/Documents/private/*.md",
  --   "BufNewFile /Users/jakob/Library/Mobile Documents/iCloud~md~obsidian/Documents/private/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "private",
        path = "/Users/jakob/Library/Mobile Documents/iCloud~md~obsidian/Documents/private",
      },
    },
    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Enables completion using blink.cmp
      blink = true,
    },

    -- Suppress deprecation warning. It is now "footer"
    statusline = {
      enabled = false,
    },
  },
}
