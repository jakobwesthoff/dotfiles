return {
  "folke/todo-comments.nvim",
  -- Load when a file buffer opens so comment highlighting attaches to it
  -- immediately; the jump/search keymaps load it on demand otherwise.
  event = { "BufReadPost", "BufNewFile" },
  -- No plenary.nvim: todo-comments needs it only for its own ripgrep search
  -- (:TodoQuickFix, :TodoLocList), which this config does not use;
  -- <leader>ft searches through fzf-lua instead.
  opts = {
    -- Default configuration. See
    -- https://github.com/folke/todo-comments.nvim#%EF%B8%8F-configuration for
    -- details
  },
}
