-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Change leader to , character
vim.g.mapleader = ","

local opt = vim.opt

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
