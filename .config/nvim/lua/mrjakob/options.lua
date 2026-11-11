-- Some keyboard mappings as I don't want to break my fingers, while typing on a "german" keyboard ;)
-- Essentially this remaps [] to ü+ with all its modifier key combinations as well.
-- 'langmap' applies in Normal, Visual and Operator-pending mode only, so ü and +
-- still type themselves in Insert and Select mode (snippet placeholders). It
-- reaches [x/]x mappings for the multibyte ü since Neovim 0.13.
vim.opt.langmap = "ü[+]"

vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.shiftwidth = 4 -- Amount to indent with << and >>
vim.opt.tabstop = 4 -- How many spaces are shown per Tab
vim.opt.softtabstop = 4 -- How many spaces are applied when pressing Tab

vim.opt.smartindent = true

-- Always show relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Show line under cursor
vim.opt.cursorline = true
-- Show column of cursor
-- vim.opt.cursorcolumn = true

-- Tree-sitter folding is enabled window-local wherever tree-sitter runs (see
-- plugins/treesitter.lua). Open files fully unfolded so folds are opt-in
-- rather than collapsing everything.
vim.opt.foldlevelstart = 99

-- Store undos between sessions
vim.opt.undofile = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Disable commandline until it is needed. This gives us a cleaner look and an extra line ;)
-- Messages then show in ui2's msg window (enabled in setup.lua).
vim.opt.cmdheight = 0

-- Apply rounded borders to all floating windows globally (LSP hover,
-- signature help, diagnostics, code actions, completion docs, etc.).
vim.o.winborder = "rounded"

-- The language providers only serve remote plugins written in Python, Node,
-- Perl or Ruby. No installed plugin is one, so the hosts stay off.
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
