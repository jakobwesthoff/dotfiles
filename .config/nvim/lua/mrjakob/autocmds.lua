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

-- Yanks into + and * reach two clipboards. Neovim's auto-detected provider
-- (pbcopy, wl-copy, xclip, tmux) fills the clipboard of the machine Neovim runs
-- on and handles paste. This OSC 52 sequence additionally asks the terminal in
-- front of the user to set its clipboard, so a yank over SSH lands on the
-- machine the user sits at. Neovim's own OSC 52 provider would replace the
-- local tool instead of adding to it, and pasting through it needs the
-- terminal to grant clipboard reads.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("OSC52Yank", { clear = true }),
  pattern = "*",
  callback = function()
    local event = vim.v.event
    if event.regname == "+" or event.regname == "*" then
      local text = table.concat(event.regcontents, "\n")
      -- Both registers target the clipboard ("c"), not "p" for *: the
      -- terminal in front of the user is Ghostty on macOS, which has no
      -- primary selection, so "*y would otherwise reach nothing over SSH.
      local osc = string.format("\027]52;c;%s\027\\", vim.base64.encode(text))
      -- nvim_ui_send writes to the attached UI's terminal, which stderr is
      -- not for remote UIs or after :detach/:connect.
      vim.api.nvim_ui_send(osc)
    end
  end,
  desc = "Emit OSC 52 for clipboard register yanks",
})
