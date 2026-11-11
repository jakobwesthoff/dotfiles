-- Highlight text briefly after yanking or putting to provide visual feedback
vim.api.nvim_create_autocmd({ "TextYankPost", "TextPutPost" }, {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*",
  callback = function()
    vim.hl.hl_op()
  end,
  desc = "Highlight yank and put",
})

-- Restore the cursor to its last position when a file is opened, following
-- the recipe in `:h restore-cursor`. BufReadPre arms a buffer-local FileType
-- handler that runs once, after filetype detection, so the filetype checks
-- below see the real filetype and the jump happens exactly once per file
-- read. Commit messages, rebase todos, xxd dumps and diff mode are left at
-- the top, as in the recipe.
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
  callback = function(ev)
    vim.api.nvim_create_autocmd("FileType", {
      buf = ev.buf,
      once = true,
      callback = function()
        local line = vim.fn.line([['"]])
        local ft = vim.bo.filetype
        if
          line >= 1
          and line <= vim.fn.line("$")
          and not ft:find("commit")
          and ft ~= "xxd"
          and ft ~= "gitrebase"
          and not vim.wo.diff
        then
          -- zz centres the restored line in the window.
          vim.cmd([[normal! g`"zz]])
        end
      end,
    })
  end,
  desc = "Restore last cursor position",
})

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
