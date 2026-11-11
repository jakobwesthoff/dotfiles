# Track dressing.nvim replacement (archived upstream; snacks.input bug still unfixed)

Created: 2026-06-11, from the 2026-06-11 full-config code review.
Updated: 2026-11-11, from the 2026-11-11 config modernization review.

## Situation

`lua/mrjakob/plugins/dressing.lua` keeps stevearc/dressing.nvim for
`vim.ui.input` only (select is disabled; fzf-lua owns `vim.ui.select`).
The spec's comment documents why snacks.input was rejected: with
default text provided (e.g. LSP rename), the cursor starts at column 0
instead of at the end of the text.

Facts:

- dressing.nvim is **archived**. Its README opens with: "This plugin is
  archived! It still works, but I recommend that you use snacks.nvim
  instead" (installed copy, README.md:4, pointing at
  stevearc/dressing.nvim issue #190 for rationale). Verified 2026-06-11.
- The bug **still reproduces** (Jakob, 2026-11-11, real TUI, Neovim
  v0.13.0-dev-1966): `:lua Snacks.input({ default = "foobar" },
  function(v) print(v) end)` leaves the cursor at column 0.
- The installed snacks.nvim (882c996, 2026-05-25) carries the newest
  input code: the last upstream commit touching `lua/snacks/input.lua`
  is 3024376 (2025-11-08), checked with
  `gh api 'repos/folke/snacks.nvim/commits?path=lua/snacks/input.lua'`.
- The earlier root-cause note here was wrong. snacks does position the
  cursor: after writing the default text (`snacks/input.lua:233-235`) it
  runs `startinsert!` in the input window (`input.lua:255-257`), which
  appends at the end of the line. Why the cursor still ends at column 0
  is not established. Hypothesis: the input buffer is a prompt buffer
  (`buftype=prompt`), and Neovim's prompt-buffer handling of
  `startinsert!` differs from a normal buffer.

Conclusion: the keep-dressing rationale in the spec comment remains
valid. This todo exists so the situation doesn't silently rot, since
an archived plugin receives no fixes if Neovim's float/input APIs shift.

## Actions

1. **Optional but useful:** report the bug upstream at
   folke/snacks.nvim with the one-line repro above and the Neovim
   version. An upstream report makes the re-evaluation condition
   concrete instead of "check occasionally".
2. **Re-check trigger:** on snacks.nvim updates that touch
   `lua/snacks/input.lua`
   (`git -C ~/.local/share/nvim/lazy/snacks.nvim log --oneline -- lua/snacks/input.lua`)
   or Neovim changes to prompt buffers, re-run the one-line repro, then
   LSP rename (`<leader>cr`) on a symbol: the cursor must land at the
   end of the prefilled name, and mid-text editing must work.
3. When it passes: enable `input` in the snacks spec, delete
   dressing.lua, re-run the rename test.

## Basis

Installed plugin sources and git history as cited; upstream commit list
via `gh api` (2026-11-11); Jakob's TUI re-test (2026-11-11); config
comment in dressing.lua:1-9 (user-documented prior evaluation).
