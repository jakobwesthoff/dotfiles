# Fix lualine colors that go stale on colorscheme/background change

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/lualine.lua` mixes two color mechanisms with
different refresh behavior:

- **Self-healing:** `options.theme` is a *function* (lualine.lua:65-84).
  lualine re-runs `setup()` on colorscheme changes — installed lualine
  source registers `autocmd lualine ColorScheme * lua
  require'lualine'.setup()` and the same for `OptionSet background`
  (`lua/lualine.lua:279-280`) — so the function is re-evaluated and the
  mode colors stay correct.
- **Stale:** `inactive_primary_color` (lualine.lua:58-61) and the
  inactive filename color `{ fg = require("mrjakob.util").getColor("Grey", "fg") }`
  (lualine.lua:192) are evaluated **once** in the `config` function and
  stored as literal hex strings inside the config table that the
  re-run `setup()` reuses. After any runtime colorscheme or background
  change they keep the old palette.

Related `util.lua` issue feeding this: `getColor` formats
`hl[attr] or 0` (`util.lua:10`), so a group lacking the requested
attribute silently yields `"#000000"` instead of nil — errors hide as
black elements. The `if not hl` guard at util.lua:7-9 is dead code:
`nvim_get_hl` always returns a table (headless probe during review:
unknown group returns an empty dict).

## Evidence / basis

- Config read: `lualine.lua:55-61, :160-206`, `util.lua:4-12`.
- Installed lualine source: `lua/lualine.lua:279-280` (ColorScheme /
  OptionSet background → `setup()` re-run).
- Headless probe on the running build: `nvim_get_hl(0, {name="NoSuchGroup"})`
  returns a table, never nil.

## Fix

1. Make the per-component colors functions so they re-evaluate on every
   refresh (lualine supports function values for `color`):

```lua
local function inactive_primary_color()
  return {
    fg = require("mrjakob.util").getColor("Normal", "bg"),
    bg = require("mrjakob.util").getColor("Grey", "fg"),
  }
end
-- usage: color = inactive_primary_color  (pass the function, not the call)
```

Verify against the installed lualine version that `color` accepts a
function for these component types; if not, recompute the table inside
a ColorScheme autocmd and call `require("lualine").setup(config)` with
the rebuilt table.

2. In `util.getColor`, return nil for missing attributes and drop the
   dead guard:

```lua
function M.getColor(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group })
  if hl[attr] == nil then
    return nil
  end
  return string.format("#%06x", hl[attr])
end
```

Then audit the call sites for nil-handling (lualine color tables accept
nil fg/bg; `newColorWithBase` overrides pass through `nvim_set_hl`).

## Context note

The config currently pins `background = "dark"` with an
"AUTO CHANGE MARKER: LIGHT/DARK" comment (gruvbox-material.lua:73-74),
which suggests an external light/dark switching mechanism exists or is
planned — exactly the scenario where these stale colors would bite.
