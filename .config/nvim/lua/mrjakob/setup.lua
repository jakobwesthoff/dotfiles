-- Map the leader key as it is needed by lazy. Set the local leader here too
-- (lazy snapshots both at setup) so filetype-local <localleader> maps share
-- the same prefix instead of falling back to the default backslash.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "mrjakob.plugins" },
  },
})

-- Loading additional configs
require("mrjakob.options")
require("mrjakob.autocmds")
require("mrjakob.keymaps")
require("mrjakob.lastpos")
require("mrjakob.lsp")

-- EXPERIMENTAL: native redesigned message/cmdline UI (vim._core.ui2). It is an
-- unstable, in-development feature: the module already moved once
-- (vim._extui -> vim._core.ui2) and its API may keep changing or break across
-- nvim updates, hence the pcall. Keep an eye on it (message rendering, fzf-lua
-- floats, fidget, tmux); remove this block to fall back to the classic
-- message UI.
pcall(function()
  require("vim._core.ui2").enable({
    -- Route messages to the ephemeral msg window.
    msg = { targets = "msg" },
  })
end)
