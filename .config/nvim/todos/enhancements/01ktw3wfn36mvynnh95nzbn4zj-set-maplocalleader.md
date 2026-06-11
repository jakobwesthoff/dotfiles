# Set `maplocalleader` explicitly

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). Small item.

## Situation

`lua/mrjakob/setup.lua:2` sets `vim.g.mapleader = ","` before lazy.nvim
bootstraps (correct placement — the comment there documents why).
`vim.g.maplocalleader` is never set anywhere in the config (grep of
`lua/` during review), so it stays at the default backslash.

lazy.nvim snapshots both leaders at setup to warn when they change
afterwards (installed lazy.nvim, `lua/lazy/core/config.lua:323` and
`loader.lua:54`), which is why the conventional place is directly next
to `mapleader`.

Relevance: `<localleader>` is the conventional prefix for
filetype-local mappings — obsidian.nvim and ftplugin-style configs are
the typical consumers in a setup like this. No plugin in the current
config is *known* to register `<localleader>` maps (not exhaustively
verified), so today this is about being deliberate rather than fixing
a malfunction: an unset localleader means any future plugin or ftplugin
`<localleader>` mapping lands on `\` silently.

## Fix

In `setup.lua`, next to mapleader:

```lua
vim.g.mapleader = ","
vim.g.maplocalleader = ","   -- or a distinct key, e.g. "\\" kept explicit, or ";"
```

Decide the value consciously: same as leader (simple, risks prefix
collisions between global and filetype maps) or distinct (e.g. `;`).

## Basis

Config grep (no maplocalleader assignment); installed lazy.nvim source
lines cited (read 2026-06-11).
