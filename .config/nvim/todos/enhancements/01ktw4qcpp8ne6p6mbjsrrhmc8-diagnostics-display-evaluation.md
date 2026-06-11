# Evaluate inline diagnostics display (virtual_text / virtual_lines)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). Enhancement evaluation — current
behavior is a deliberate-looking minimal setup, not a bug.

## Current state

The only diagnostics configuration is the sign icons
(`lua/mrjakob/plugins/lsp.lua:159-165`:
`vim.diagnostic.config({ signs = { text = diagnostic_signs } })`).
Diagnostics are therefore visible as: gutter signs, `gl` float on
demand (`keymaps.lua:5`), the lualine diagnostics component
(`lualine.lua:107-118`), fzf pickers, and native `[d`/`]d` navigation.
No inline text at the offending line. A global toggle exists at
`<leader>ud` (`keymaps.lua:11-13`).

## What native Neovim offers (running build)

`vim.diagnostic.config()` accepts, among others:

- `virtual_text` — per-line trailing text for diagnostics (long
  available).
- `virtual_lines` — whole virtual lines below the diagnostic, with the
  full message (added in 0.11; on the running build see
  `:help vim.diagnostic.Opts.virtual_lines`).

A common middle ground is current-line-only inline display, e.g.
`virtual_lines = { current_line = true }`, keeping other lines clean
while showing the full message where the cursor is — which would
partially replace the manual `gl` habit.

## Decision to make

Whether the on-demand-only model (`gl`) is the preference, or whether
one of:

```lua
vim.diagnostic.config({
  signs = { text = diagnostic_signs },        -- existing
  virtual_text = { severity = vim.diagnostic.severity.ERROR },
})
-- or
vim.diagnostic.config({
  signs = { text = diagnostic_signs },
  virtual_lines = { current_line = true },
})
```

improves the workflow. Try each for a day in a diagnostics-heavy
project; the `<leader>ud` toggle keeps the escape hatch. If the
on-demand model wins, record that decision in a comment next to the
`vim.diagnostic.config` call so the question doesn't resurface.

## Basis

Config reads as cited; `vim.diagnostic.config` options from the running
build's documentation (`:help vim.diagnostic.Opts`). The
`current_line` suggestion is from the same help page; verify the exact
option shape there when implementing.
