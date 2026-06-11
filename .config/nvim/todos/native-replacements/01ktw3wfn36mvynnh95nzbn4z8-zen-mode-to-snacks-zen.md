# Consolidate folke/zen-mode.nvim into snacks.zen

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Situation

`lua/mrjakob/plugins/zen-mode.lua` loads `folke/zen-mode.nvim` with
snacks.nvim as a dependency, solely to toggle zen on `<leader>z` with
width 100, some window options, and manual
`Snacks.indent.disable()`/`enable()` in `on_open`/`on_close`
(zen-mode.lua:26-33).

snacks.nvim — already installed and loaded for indent guides — ships
its own zen module:

- `snacks/zen.lua` (`M.meta.desc = "Zen mode"`).
- Its config takes `toggles` keyed by `Snacks.toggle` ids
  (zen.lua:14-25); `snacks/toggle.lua:287-298` defines an `indent`
  toggle wired to `Snacks.indent.enable()/disable()`. Toggle state "is
  restored when the window is closed" (zen.lua:16). This replaces the
  manual on_open/on_close callbacks entirely.
- Window width and `wo` options map onto the zen win style
  (zen.lua:52-67, default width 120, overridable via `win`).
- One behavioral note: snacks.zen's statusline hiding only applies with
  `laststatus = 3` (zen.lua:89); this config uses per-window
  statuslines (lualine `globalstatus = false`), and `show.statusline =
  false` is snacks' default anyway, so nothing changes there.

## Evidence / basis

- Config read: `zen-mode.lua`, `snacks.lua`.
- Installed snacks source at the paths/lines cited (read 2026-06-11).

## Fix

1. Extend the existing snacks spec (`snacks.lua`) with:

```lua
opts = {
  indent = { ... },          -- existing
  zen = {
    toggles = { indent = false },
    win = {
      width = 100,
      wo = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorcolumn = false,
      },
    },
  },
},
keys = {
  { "<leader>z", function() Snacks.zen() end, desc = "Toggle [Z]en Mode" },
},
```

(Exact nesting of `win`/`wo` for the zen style: verify against the
installed snacks docs (`snacks/zen.lua` header) when implementing —
the option shape above is reconstructed from the source read and needs
a live check.)

2. Delete `lua/mrjakob/plugins/zen-mode.lua`.

## Result

One plugin fewer, no manual indent-state bookkeeping, and zen behavior
owned by the plugin already responsible for the indent guides it
toggles.
