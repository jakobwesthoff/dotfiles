return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
      indent = {
        enabled = false, -- Enable to show all indent guides not only the current scope
        only_current = true, -- only current window
        only_scope = true, -- only on scope
      },
      scope = {
        enabled = true,
        only_current = true, -- only current window
      },
      chunk = {
        enabled = false,
        only_current = false, -- only current window
      },
      -- filter for buffers, turn off the indents for markdown
      filter = function(buf)
        return vim.g.snacks_indent ~= false
          and vim.b[buf].snacks_indent ~= false
          and vim.bo[buf].buftype == ""
          and vim.bo[buf].filetype ~= "markdown"
      end,
    },
  },
}
