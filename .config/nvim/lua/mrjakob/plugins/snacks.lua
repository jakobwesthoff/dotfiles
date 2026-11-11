return {
  "folke/snacks.nvim",
  -- snacks recommends loading early and eagerly for its UI modules.
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Only the current scope gets a guide, and only in the current window.
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
      indent = {
        enabled = false, -- Enable to show all indent guides not only the current scope
      },
      scope = {
        only_current = true, -- only current window
      },
      -- snacks' default buffer filter, plus no guides in markdown
      filter = function(buf)
        return vim.g.snacks_indent ~= false
          and vim.b[buf].snacks_indent ~= false
          and vim.bo[buf].buftype == ""
          and vim.bo[buf].filetype ~= "markdown"
      end,
    },
  },
}
