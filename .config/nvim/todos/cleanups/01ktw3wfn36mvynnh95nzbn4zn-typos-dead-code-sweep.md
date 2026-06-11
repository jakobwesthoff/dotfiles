# Typos, dead code, and small-inconsistency sweep

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). One sweep of mechanical items; none
changes behavior except where explicitly marked **[behavior]**. Every
item verified by direct read of the cited line (plus plugin/runtime
source where noted), 2026-06-11.

## keymaps.lua

- `:17` **[behavior]** `vim.keymap.set("x", "<C-BS>", "<C-w>")` — the
  surrounding comment (line 15) says "in insert mode"; in visual mode
  `<C-w>` has no delete-word meaning, the mapping does nothing useful.
  Either delete it or change the mode to `"c"` (cmdline word-delete,
  `c_CTRL-W`).
- `:25` desc typo: "Jump to to Window".
- `:43` comment typo: "follwoing".
- `:69-74` **[behavior]** the `gr*` unmap loop runs `vim.keymap.del("n",
  ...)` only; the runtime also maps `gra` in visual mode
  (`runtime/lua/vim/_core/defaults.lua:208`, `{'n','x'}`), which
  survives. Add an x-mode del for `gra` (pcall-wrapped). Also: the loop
  runs on every LspAttach; deleting defaults once at startup is enough.
- `:165-166` use `require("fzf-lua")` although `local fzf` exists since
  line 150 — use `fzf.lsp_workspace_symbols` / `fzf.lsp_document_symbols`.

## options.lua

- `:1-6` the langmap `ü`/`+` *keymaps* (lines 5-6) live in options.lua;
  the file split says they belong in keymaps.lua. Move them together
  with the `vim.opt.langmap` line or leave all three with a comment —
  currently the mapping half is where nobody will look for it.
- `:23` comment typo: "Show column of cursor cursor" (above a
  commented-out option; decide whether the dead `cursorcolumn` line
  stays as documentation or goes).

## autocmds.lua

- `:11-20` the OSC52 explanation paragraph is duplicated nearly
  verbatim (lines 11-14 vs 16-20). Moot if the autocmd is removed per
  `todos/native-replacements/*-osc52-native-clipboard.md`; otherwise
  keep one copy.

## util.lua

- `:7-9` dead guard: `vim.api.nvim_get_hl` always returns a table
  (headless probe on the running build), `if not hl` never fires.
- `:17` `new_color.link = nil` on a fresh empty table is a no-op.
- (The `hl[attr] or 0` → `#000000` issue is handled in
  `todos/bugs/*-lualine-stale-theme-colors.md`, fix them together.)

## harpoon.lua

- `:30-32` desc "[q] Harpoon to 2" → "[w]".
- `:36-38` desc "[e] Harpoon to 4" → "[r]".
- `:39-41` desc "[q] Harpoon to 5" → "[t]".
- `:47` desc typo "Hardpoon".

## blink-cmp.lua

- `:22, :31` **[behavior-neutral]** `border = "rounded"` twice — blink
  falls back to `vim.o.winborder` (set to "rounded" in options.lua:69)
  when border is nil (installed blink source,
  `lua/blink/cmp/config/shared.lua:2`,
  `lua/blink/cmp/lib/window/utils.lua:9-12`). Drop both lines; one
  source of truth for borders.

## mason.lua

- `:17` `shellcheck` sits under the "LSP servers" comment; it is a CLI
  linter (bash-language-server uses it for diagnostics when present).
  Move it under "Formatters / linters".

## ts-autotag.lua

- `:4` `config = true` is the legacy spelling; use `opts = {}` like
  every other spec in this config.

## flash.lua

- `:4` the `---@type Flash.Config` annotation sits above `config =
  function()` and annotates nothing; move it onto an `opts` table or
  delete it.

## fzf.lua

- `:44` **[behavior]** `fzf_lua.fzf_exec("fd --type d", opts)` assumes
  `fd` exists (it does today: /opt/homebrew/bin/fd); without it the
  picker opens empty with no error. Add a
  `vim.fn.executable("fd") == 1` guard with a notify, since
  `FzfDirectories` is also reachable via `<leader>fp`.
