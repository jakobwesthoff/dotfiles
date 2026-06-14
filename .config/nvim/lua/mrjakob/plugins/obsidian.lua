return {
  "obsidian-nvim/obsidian.nvim",
  -- Eager so the :Obsidian* commands are usable from any buffer, not only
  -- after a markdown file has been opened.
  lazy = false,
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
    -- Suppress deprecation warning. It is now "footer"
    statusline = {
      enabled = false,
    },
  },
}
