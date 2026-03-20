-- Only used for vim.ui.input (rename, etc.)
-- vim.ui.select is handled by fzf-lua.
--
-- snacks.input is not a viable replacement in our setup: with input
-- enabled, the cursor starts at column 0 when default text is provided
-- (e.g. LSP rename) instead of at the end, making editing unreliable.
-- We were unable to find a fix within snacks itself — only an external
-- FileType autocmd workaround partially helped but broke mid-text
-- editing. Re-evaluate once snacks.input matures or our setup changes.
return {
  "stevearc/dressing.nvim",
  opts = {
    select = { enabled = false },
  },
}
