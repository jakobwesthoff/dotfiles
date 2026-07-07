# Track dressing.nvim replacement (archived upstream; snacks.input bug still unfixed)

Created: 2026-06-11, from the 2026-06-11 full-config code review, since
resolved and removed.

## Situation

`lua/mrjakob/plugins/dressing.lua` keeps stevearc/dressing.nvim for
`vim.ui.input` only (select is disabled; fzf-lua owns `vim.ui.select`).
The spec's comment documents why snacks.input was rejected: with
default text provided (e.g. LSP rename), the cursor starts at column 0
instead of at the end of the text.

Facts verified 2026-06-11:

- dressing.nvim is **archived**. Its README opens with: "This plugin is
  archived! It still works, but I recommend that you use snacks.nvim
  instead" (installed copy, README.md:4, pointing at
  stevearc/dressing.nvim issue #190 for rationale).
- The snacks.input cursor bug **still exists** in the installed,
  current snacks.nvim (HEAD ad9ede6, 2026-03-21): the default-text path
  does `nvim_buf_set_lines(win.buf, 0, -1, false, { opts.default })`
  with no cursor positioning (`snacks/input.lua:234-236`), while the
  `set()` helper that *does* place the cursor at end-of-text
  (input.lua:162-166) is not used for the default value.
- `git log --oneline -20 -- lua/snacks/input.lua` shows recent input
  fixes (completion, zindex, stopinsert scheduling) but none touching
  cursor placement for default text.

Conclusion: the keep-dressing rationale in the spec comment remains
valid. This todo exists so the situation doesn't silently rot — an
archived plugin receives no fixes if Neovim's float/input APIs shift.

## Actions

1. **Optional but useful:** file the cursor-position issue upstream at
   folke/snacks.nvim (or a PR — the fix is plausibly routing the
   default through the existing `set()` helper at input.lua:162-166;
   verify side effects first). The dressing.lua comment says "We were
   unable to find a fix within snacks itself"; an upstream report makes
   the re-evaluation condition concrete instead of "check
   occasionally".
2. **Re-check trigger:** on snacks.nvim updates that touch
   `lua/snacks/input.lua` (the check used in this review:
   `git -C ~/.local/share/nvim/lazy/snacks.nvim log --oneline -- lua/snacks/input.lua`),
   re-test: LSP rename (`<leader>cr`) on a symbol — cursor must land at
   the end of the prefilled name, and mid-text editing must work.
3. When it passes: enable `input` in the snacks spec, delete
   dressing.lua, re-run the rename test.

## Basis

Installed plugin sources and git history as cited (read 2026-06-11);
config comment in dressing.lua:1-9 (user-documented prior evaluation).
