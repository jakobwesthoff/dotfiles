# Fix `constrast` typo in gruvbox-material setup (theme silently runs at medium contrast)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/gruvbox-material.lua:13` passes:

```lua
require("gruvbox-material").setup({
  constrast = "hard",   -- misspelled; the option is `contrast`
  ...
})
```

The installed plugin (`f4z3r/gruvbox-material.nvim`) defines the option
as `contrast` with default `"medium"`
(`~/.local/share/nvim/lazy/gruvbox-material.nvim/lua/gruvbox-material/init.lua:6`).
Its `apply_defaults` (init.lua:28-41) carries unknown keys through
without validation, so the typo is silently ignored and highlight groups
are built with the medium palette (`groups.get(cfg.contrast)`,
init.lua:69).

Meanwhile the `customize` callback in the same spec explicitly fetches
the hard palette: `colors.get(vim.o.background, "hard")`
(gruvbox-material.lua:19). The contrast-sensitive value used there is
`colors.bg3` for `Pmenu*`/`NormalFloat` backgrounds
(gruvbox-material.lua:47): hard bg3 = `#3c3836`, medium bg3 = `#45403d`
(plugin colors.lua:54 and :77). Result: popup/float backgrounds use
hard-palette shades on top of a theme rendered with the medium palette,
and the intended hard contrast is never applied.

The accent colors used in the other customize branches (orange, aqua,
yellow) come from the contrast-independent base table (plugin
colors.lua:5-45), so those overrides are unaffected by the typo.

## Evidence / basis

- Config read: `gruvbox-material.lua:13` and `:19`.
- Installed plugin source: `init.lua:6` (option name + default),
  `init.lua:28-41` (no key validation), `init.lua:69` (groups built from
  `cfg.contrast`), `colors.lua:54/:77` (bg3 values per contrast).

## Fix

1. Rename the key: `contrast = "hard"`.
2. Make the customize callback reuse the configured value instead of a
   second literal, so the two cannot drift again. The plugin has no
   getter for the configured contrast; simplest is a single local:

```lua
local contrast = "hard"
require("gruvbox-material").setup({
  contrast = contrast,
  ...
  customize = function(group, opts)
    local colors = require("gruvbox-material.colors").get(vim.o.background, contrast)
    ...
```

3. Visually verify after the fix: overall background/contrast will
   change (medium → hard) since the theme was effectively running at
   medium until now. Decide whether hard is actually the wanted look —
   the config has been displaying medium all along.
