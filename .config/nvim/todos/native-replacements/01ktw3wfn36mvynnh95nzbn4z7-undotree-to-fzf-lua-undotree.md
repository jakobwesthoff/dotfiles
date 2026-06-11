# Replace mbbill/undotree with fzf-lua's built-in undotree picker

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). Directly answers the existing FIXME
at `keymaps.lua:188`: "Maybe there is a faster more current way of
showing this undo history?"

## Situation

- `lua/mrjakob/plugins/undotree.lua` loads `mbbill/undotree`
  (vimscript plugin, `lazy = false`), used only via `<leader>uu` →
  `:UndotreeToggle` (`keymaps.lua:189-191`).
- The installed fzf-lua — already this config's picker for everything
  else — ships an undotree provider:
  - registered: `fzf-lua/lua/fzf-lua/init.lua:268`
    (`undotree = { "fzf-lua.providers.undotree", "undotree" }`)
  - implementation: `fzf-lua/lua/fzf-lua/providers/undotree.lua`
  - defaults incl. an undo-diff previewer: `defaults.lua:1864` and
    `defaults.lua:361-377`
  - callable as `require("fzf-lua").undotree()` or `:FzfLua undotree`.
- snacks.nvim (installed) also has an undo picker
  (`snacks/picker/config/sources.lua:1052-1056`), but this config does
  not enable snacks.picker (snacks.lua enables only `indent`), so
  fzf-lua is the natural fit.

## Evidence / basis

- Installed plugin sources at the paths/lines cited (read 2026-06-11).
- Config: `undotree.lua`, `keymaps.lua:187-191`, `snacks.lua` (only
  indent configured), `fzf.lua` (fzf-lua as ui_select provider).

## Fix

1. `keymaps.lua`: point the mapping at fzf-lua and drop the FIXME:

```lua
vim.keymap.set("n", "<leader>uu", function()
  require("fzf-lua").undotree()
end, { desc = "[U]ndo history [U]i" })
```

2. Delete `lua/mrjakob/plugins/undotree.lua`.

## Trade-offs to check before committing

The fzf-lua picker is a flat list with diff preview; mbbill/undotree
renders the undo *tree* structure (branches visible as a tree drawing)
and supports live navigation in a persistent sidebar. If undo
*branches* (not just history states) are part of the actual workflow,
test the picker against a buffer with branched undo history first.
If the tree view turns out to matter, keep mbbill/undotree but load it
lazily instead: `cmd = "UndotreeToggle"` in the spec, replacing
`lazy = false` (only entry point is the command).
