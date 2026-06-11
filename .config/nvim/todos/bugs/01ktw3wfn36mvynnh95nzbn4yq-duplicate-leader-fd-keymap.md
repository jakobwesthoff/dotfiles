# Fix duplicate `<leader>fd` keymap (diagnostics picker unreachable)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`<leader>fd` is defined twice in normal mode in
`lua/mrjakob/keymaps.lua`:

- `keymaps.lua:160`:
  `vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "[F]ind [D]iagnostics" })`
- `keymaps.lua:172-174`:
  `vim.keymap.set("n", "<leader>fd", function() fzf.files({ cwd = os.getenv("HOME") .. "/dotfiles" }) end, { desc = "[F]ind [D]otfiles" })`

Both calls run sequentially in the same file; `vim.keymap.set` silently
overwrites, so the dotfiles search (line 172) wins and the document
diagnostics picker is unreachable from any mapping.

## Evidence / basis

- Direct read of `keymaps.lua` during review: same lhs, same mode `"n"`,
  two `vim.keymap.set` calls.
- Confirmed independently by two review agents reading the file.

## Fix

Rebind one of the two. Free candidates checked against the current
config (no existing user of these):

- diagnostics → `<leader>fx` (mnemonic: diagnostics/"problems"), or
- dotfiles → `<leader>f.` (mnemonic: dotfiles).

Note `<leader>fD` is currently free as well, but keep its case-sibling
relationship in mind: `<leader>fS`/`<leader>fs` and `<leader>fW`/
`<leader>fw` use upper/lower variants for workspace/document and
WORD/word pairs, so `<leader>fD` would suggest a "workspace diagnostics"
relationship with `<leader>fd`. If that pairing is desired:
`<leader>fd` = `fzf.diagnostics_document`, `<leader>fD` =
`fzf.diagnostics_workspace`, and dotfiles moves to `<leader>f.`.

After the change, also check the which-key picture (`<leader>f` group)
still reads sensibly.
