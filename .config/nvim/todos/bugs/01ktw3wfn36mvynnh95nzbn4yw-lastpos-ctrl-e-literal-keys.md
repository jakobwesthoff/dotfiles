# Fix `<c-e>` typed literally in lastpos.lua

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/lastpos.lua:38` runs:

```lua
vim.cmd([[normal! G'"<c-e>]])
```

`:normal` executes its argument characters "like they are typed"
(runtime `doc/various.txt:206-210`); it does **not** parse `<c-e>` key
notation. The buffer therefore receives the literal five characters
`<`, `c`, `-`, `e`, `>` as normal-mode commands after the `G'"` motion,
instead of a one-line upward scroll (CTRL-E).

The bug is latent: this branch only runs when the file's last-edit
position is close enough to the end of the buffer (the `else` branch of
the centering logic, lastpos.lua:35-39), which is why it hasn't been
noticed as corruption — the stray keys mostly resolve to failed motions.

## Evidence / basis

- Config read: `lastpos.lua:27-40` (full branch logic).
- Runtime doc of the running build: `doc/various.txt:206-210`
  (`:normal` types characters literally, no special-key parsing).
- The file header states the code was adapted from
  github.com/neovim/neovim/issues/16339#issuecomment-1348133829 /
  ethanholz/nvim-lastplace; the original context was not re-checked —
  the fix below stands on the `:normal` semantics alone.

## Fix

Use `:execute` with an escaped keycode, or feed parsed keys:

```lua
vim.cmd([[execute "normal! G'\"\<c-e>"]])
```

or

```lua
vim.api.nvim_feedkeys(vim.keycode([[G'"<C-e>]]), "nx", false)
```

## Verification

Reproduce the branch: open a file whose `'"` mark sits within half a
window-height of the last line but with the buffer longer than the
window (so neither of the first two branches triggers), and confirm the
view scrolls one line instead of the cursor jittering.
