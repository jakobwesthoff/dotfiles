-- Highlight text briefly after yanking to provide visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
  desc = "Highlight yank",
})

-- Emit OSC 52 escape sequence when yanking to system clipboard registers (* and +).
-- This tells the terminal emulator to set the system clipboard contents, which works
-- even over SSH or in environments without direct clipboard access. This runs in
-- addition to Neovim's auto-detected native clipboard provider.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("OSC52Yank", { clear = true }),
  pattern = "*",
  callback = function()
    local event = vim.v.event
    if event.regname == "+" or event.regname == "*" then
      require("vim.ui.clipboard.osc52").copy(event.regname)(event.regcontents)
    end
  end,
  desc = "Emit OSC 52 for clipboard register yanks",
})
