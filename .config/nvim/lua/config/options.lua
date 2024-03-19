-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Change leader to , character
vim.g.mapleader = ","

local opt = vim.opt

opt.background = "light"

opt.spelllang = { "en", "de" }

vim.g.autoformat = false

-- Seperate vim registers and system clipboard
opt.clipboard = ""

opt.confirm = false

opt.relativenumber = false

opt.list = true
opt.listchars = { tab = "▸ ", eol = "¬" }

-- opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:block"
-- opt.guicursor = ""

opt.conceallevel = 0

-- Create W and w!! command
vim.cmd("command! -nargs=0 W SudaWrite")
-- Does not work yet
-- vim.cmd("cnoreabbrev <expr> w!! SudaWrite")
