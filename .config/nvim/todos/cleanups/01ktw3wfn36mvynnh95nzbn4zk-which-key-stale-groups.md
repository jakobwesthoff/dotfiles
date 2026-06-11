# Remove stale which-key groups inherited from kickstart.nvim

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/which-key.lua:19-27` declares seven leader groups.
A full-config grep for mappings under each prefix (done during review)
shows four of them describe mappings that do not exist in this config —
they are leftovers from the kickstart.nvim template this section came
from:

- `{ "<leader>d", group = "[D]ocument" }` (line 21) — no `<leader>d…`
  mappings exist. (`<leader>D` = type definition is a *different* key.)
- `{ "<leader>r", group = "[R]ename" }` (line 22) — rename moved to
  `<leader>cr` (keymaps.lua:141). `<leader>r` is actually harpoon
  "select 4" (harpoon.lua:36-38), so which-key shows a wrong label for
  a real mapping.
- `{ "<leader>w", group = "[W]orkspace" }` (line 24) — no workspace
  mappings; `<leader>w` is harpoon "select 2" (harpoon.lua:30-32).
- `{ "<leader>h", group = "Git [H]unk" }` (line 26) — no gitsigns (or
  any git plugin) is installed; nothing maps `<leader>h…`.

The remaining three groups are accurate: `<leader>c` ([C]ode →
`<leader>ca`, `<leader>cr`, `<leader>cf`), `<leader>f` ([F]ind → many),
`<leader>u` ([U]i → `<leader>ud`, `<leader>uh`, `<leader>uu`).

## Evidence / basis

- Config grep for `<leader>d/r/w/h` mappings across `lua/` (review,
  2026-06-11): only which-key.lua itself matches.
- harpoon.lua:14-41 (the real `<leader>r`/`<leader>w` owners),
  keymaps.lua:141 (rename at `<leader>cr`).
- Plugin list read in full: no git plugin present.

## Fix

Delete lines 21, 22, 24, 26 from the `spec` table. Optionally run
`:checkhealth which-key` afterwards — it reports group/mapping overlap
issues and would have flagged the `<leader>r`/`<leader>w` conflicts.

If harpoon mappings should be *grouped* in the which-key popup instead,
that's a different change (add descriptive group-less icons or a
`<leader>` harpoon prefix); the current single-key harpoon design
(`<leader>q/w/e/r/t/a/l`) intentionally has no group prefix.
