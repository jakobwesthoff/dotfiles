return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    input = { enabled = true },  -- workaround for cursor position below
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
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Workaround: snacks.input uses a prompt buffer where `startinsert!`
    -- doesn't reliably place the cursor after pre-filled default text.
    -- Force cursor to end of line once the input window opens.
    -- TODO: Remove once fixed upstream in folke/snacks.nvim
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "snacks_input",
      callback = function()
        vim.schedule(function()
          local line = vim.api.nvim_get_current_line()
          vim.api.nvim_win_set_cursor(0, { 1, #line })
        end)
      end,
    })
  end,
}
