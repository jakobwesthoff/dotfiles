# Make lualine truncation react to window width, not terminal width

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/lualine.lua` truncates statusline elements below 80
columns:

```lua
-- lualine.lua:3-7
local lualine_trunc_margin = 80
local function truncateCondition()
  return vim.o.columns >= lualine_trunc_margin
end
```

`vim.o.columns` is the **full terminal width**. The config deliberately
uses per-window statuslines (`globalstatus = false`, lualine.lua:95,
with a window-number component for the `<Leader>1-6` jump maps). With
vertical splits, each window's statusline is far narrower than the
terminal, but `truncateCondition()` and `formatMode` (lualine.lua:22)
still see the terminal width and render the wide variants — exactly the
crowded-statusline situation the truncation exists to prevent.

## Evidence / basis

- Config read: `lualine.lua:1-50` (the three helpers), `:95`
  (globalstatus=false), `:98-159` and `:160-207` (the components using
  `truncateCondition`/`formatMode`/`getColumnPosition`/`getRowPosition`).
- `vim.o.columns` semantics: standard option, terminal width.

## Fix

Components are evaluated in the context of the window they render for,
so use the current window's width:

```lua
local function truncateCondition()
  return vim.api.nvim_win_get_width(0) >= lualine_trunc_margin
end
```

and the same inside `formatMode`. Verify the "window 0 = window being
drawn" assumption against the installed lualine's component evaluation
when implementing (lualine evaluates statusline expressions per window;
confirm with a quick two-split test: narrow split shows `N`/short
positions while a wide split shows `NORMAL`/`col⎮max` at the same
time). If the assumption does not hold for some component type, lualine
components receive no window argument in `fmt`, so the fallback is
keeping `vim.o.columns` for those.

Consider whether 80 is still the right margin once it measures windows
instead of terminals (a 100-column terminal split in two gives ~50-col
windows; mode shortening should probably kick in there, so the margin
may want to drop to ~60 for per-window measurement).
