-- Open parent directory of current file
vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

-- Show current diagnostic in a float
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show Diagnostic" })

-- Show lsp hover on CTRL-K as well as the SHIFT-K default
vim.keymap.set("n", "<C-K>", vim.lsp.buf.hover, { desc = "LSP: Show [H]over" })

-- Toggle diagnostic view
vim.keymap.set("n", "<Leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle [D]iagnostics" })

-- Delete words with CTRL-Backspace/Alt-Backspace in insert and command-line mode
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })
vim.keymap.set("c", "<C-BS>", "<C-w>", { noremap = true, silent = true })
vim.keymap.set("i", "<M-BS>", "<C-w>", { noremap = true, silent = true })

-- Jump to windows based on their window number using <Leader>number
-- Allowed for window numbers 1-6
for i = 1, 6 do
  local keys = "<Leader>" .. i
  local target = i .. "<C-W>w"
  vim.keymap.set("n", keys, target, { desc = "Jump to Window " .. i })
end

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- LSP based fzf supported keymaps
-- Only register for buffers, where the LSP actually attached.

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("keymaps-lsp-attach", { clear = true }),
  callback = function(event)
    -- All of the following gX keybindings are a little more
    -- involved, as we are checking first if there is only one
    -- match. If there is we directly go there. Otherwise we open
    -- fzf-lua for the results.

    -- Buffer-local keymap helper for the LSP mappings below; callers pass a
    -- normal opts table and the attaching buffer is injected automatically.
    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = event.buf
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- fzf-lua's LSP pickers jump straight to the location on a single result
    -- (jump1) and open the picker otherwise, so they replace the hand-rolled
    -- single-vs-many logic these mappings used to carry.

    -- [G]oto [D]efinition(s)
    map("n", "gd", function()
      require("fzf-lua").lsp_definitions()
    end, { desc = "[G]oto [D]efinition(s)" })

    -- Unmap default gr* since 0.11
    local gr_mappings = { "grr", "gra", "gri", "grn", "grt", "grx" }
    for _, keymap in ipairs(gr_mappings) do
      pcall(function()
        vim.keymap.del("n", keymap, { buffer = event.buf })
      end)
    end

    -- [G]oto [R]eference(s)
    map("n", "gr", function()
      require("fzf-lua").lsp_references()
    end, { desc = "[G]oto [R]eference(s)" })

    -- [G]oto [I]mplementation(s)
    map("n", "gI", function()
      require("fzf-lua").lsp_implementations()
    end, { desc = "[G]oto [I]mplementation(s)" })

    -- [G]oto [D]eclaration
    map("n", "gD", function()
      require("fzf-lua").lsp_declarations()
    end, { desc = "[G]oto [D]eclaration" })

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    map("n", "<leader>D", require("fzf-lua").lsp_typedefs, { desc = "Type [D]efinition" })

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "[R]ename" })

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })
  end,
})

-- FZF related general keymaps
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fp", "<cmd>FzfDirectories<CR>", { desc = "[F]ind [P]aths" })
vim.keymap.set("n", "<leader>fb", fzf.builtin, { desc = "[F]ind [B]uiltin FZF" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD, { desc = "[F]ind current [W]ORD" })
vim.keymap.set("n", "<leader>fG", fzf.live_grep, { desc = "[F]ind by Live [G]rep" })
vim.keymap.set("n", "<leader>fg", fzf.grep_project, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "[F]ind [R]esume" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "[F]ind [O]ld Files" })
vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "[,] Find existing buffers" })
vim.keymap.set("n", "<leader>/", fzf.lgrep_curbuf, { desc = "[/] Live grep the current buffer" })
vim.keymap.set("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "[F]ind Workspace [S]ymbols" })
vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "[F]ind Document [S]ymbols" })
-- Search in neovim config
vim.keymap.set("n", "<leader>fc", function()
  fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[F]ind Neovim [C]onfig files" })
-- Search in TODOs, FIXMEs, HACKs, via todo-comments.nvim
vim.keymap.set("n", "<leader>ft", function()
  require("todo-comments.fzf").todo()
end, { desc = "[F]ind [T]odos, Fixmes, Hacks, ..." })
-- Navigate between TODOs and such
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })
vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- Browse undo history with fzf-lua's undotree picker (diff preview per state)
vim.keymap.set("n", "<leader>uu", function()
  require("fzf-lua").undotree()
end, { remap = false, desc = "[U]ndo history [U]i" })

-- Keep the selection if indentlevel is changed
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
