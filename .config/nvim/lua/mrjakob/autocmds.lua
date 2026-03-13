-- Emit OSC 52 escape sequence when yanking to system clipboard registers (* and +).
-- This tells the terminal emulator to set the system clipboard contents, which works
-- even over SSH or in environments without direct clipboard access. This runs in
-- addition to Neovim's auto-detected native clipboard provider.
--
-- Write an OSC 52 escape sequence to Neovim's terminal channel when yanking to
-- system clipboard registers (* and +). This tells the terminal emulator to set
-- the system clipboard contents, which works even over SSH or in environments
-- without direct clipboard access. This runs in addition to Neovim's auto-detected
-- native clipboard provider.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("OSC52Yank", { clear = true }),
  pattern = "*",
  callback = function()
    local event = vim.v.event
    if event.regname == "+" or event.regname == "*" then
      local text = table.concat(event.regcontents, "\n")
      local b64 = vim.base64.encode(text)
      local osc = string.format("\027]52;c;%s\027\\", b64)
      vim.api.nvim_chan_send(2, osc)
    end
  end,
  desc = "Emit OSC 52 for clipboard register yanks",
})
