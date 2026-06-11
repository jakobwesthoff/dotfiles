# Fix lazydev `luvit-meta/library` reference (vim.uv types never load)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/lsp.lua:179-184` configures lazydev with:

```lua
library = {
  { path = "luvit-meta/library", words = { "vim%.uv" } },
},
```

lazydev resolves the leading path segment of a relative library path as
a *plugin name* (installed lazydev source: `workspace.lua:134-139`,
`pkg.lua:94-115`). The plugin `luvit-meta` (Bilal2453/luvit-meta) is not
installed: it has no directory under `~/.local/share/nvim/lazy/` and no
entry in `lazy-lock.json`. Resolution fails, the entry is dead, and
`vim.uv` type annotations/completion never become available in Lua
config editing.

## Evidence / basis

- Config read: `lsp.lua:179-184`.
- `ls ~/.local/share/nvim/lazy/ | grep -i luvit` → no match (verified
  during review).
- `lazy-lock.json` read in full: no luvit-meta entry.
- Installed lazydev source: `workspace.lua:134-139` and `pkg.lua:94-115`
  (plugin-name resolution of relative paths).
- Installed lazydev README (README.md:51-52, :107-108) recommends:
  `{ path = "${3rd}/luv/library", words = { "vim%.uv" } }` — uses the
  third-party definitions bundled with lua-language-server, no extra
  plugin required.

## Fix

Replace the library entry with the form recommended by the installed
lazydev README:

```lua
library = {
  { path = "${3rd}/luv/library", words = { "vim%.uv" } },
},
```

Alternative (not preferred): add `{ "Bilal2453/luvit-meta", lazy = true }`
as a plugin and keep the current path. The `${3rd}` form is one less
plugin and is what lazydev documents today.

## Verification

Open a Lua file in the nvim config, type `vim.uv.` and confirm
lua_ls offers uv API completions (e.g. `fs_stat`), and that
`vim.uv.fs_stat` hover shows typed documentation.
