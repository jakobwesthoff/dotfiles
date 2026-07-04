# nvim: gr* default-unmap is a no-op, leaving a timeoutlen delay on the `gr` LSP references mapping

**Area**: nvim
**File**: /Users/jakob/dotfiles/.config/nvim/lua/mrjakob/keymaps.lua:60-66

## Current state

Inside the `LspAttach` autocmd, the config tries to remove Neovim's default
LSP mappings before binding its own buffer-local `gr`:

```lua
-- Unmap default gr* since 0.11
local gr_mappings = { "grr", "gra", "gri", "grn", "grt", "grx" }
for _, keymap in ipairs(gr_mappings) do
  pcall(function()
    vim.keymap.del("n", keymap, { buffer = event.buf })
  end)
end
```

followed by a buffer-local `gr` mapping to `fzf-lua.lsp_references()`
(keymaps.lua:69-71).

## Problem

The default gr* mappings are **global**, not buffer-local. On the installed
build (NVIM v0.13.0-dev-3603) they are created in
`runtime/lua/vim/_core/defaults.lua:213-233` via plain
`vim.keymap.set('n', 'grn', ...)` etc. with no `buffer` argument (`gra`
additionally in mode `x`). `vim.keymap.del("n", keymap, { buffer = event.buf })`
therefore targets a buffer-local mapping that does not exist, errors with
"no such mapping", and the `pcall` silently swallows it. Net effect: nothing
is ever unmapped and the loop is dead code.

Two consequences:

1. The global defaults `grr`, `gra`, `gri`, `grn`, `grt`, `grx` all remain
   active.
2. Because the buffer-local `gr` is a prefix of those still-existing global
   mappings, Neovim must wait to disambiguate. Per `:h map-nowait`
   (runtime/doc/map.txt:198-203 on the installed build): "When defining a
   buffer-local mapping for ',' there may be a global mapping that starts
   with ','. Then you need to type another character for Vim to know whether
   to use the ',' mapping or the longer one." So pressing `gr` only triggers
   the fzf references picker after `timeoutlen` (default 1000 ms) or a
   subsequent non-matching key.

## Grounding

- `grep -n "grr\|grn\|gra\|gri\|grt\|grx" /opt/homebrew/Cellar/neovim/HEAD-aa3823c/share/nvim/runtime/lua/vim/_core/defaults.lua`
  shows all six defaults defined globally at lines 213-233 (`gra` at 217 in
  modes `{ 'n', 'x' }`).
- `runtime/doc/map.txt:752-761` (`map-precedence`) plus `:198-203`
  (`map-nowait`) document the prefix-ambiguity wait and that `<nowait>` is
  the escape hatch for exactly this buffer-local-shadows-global case.
- `vim.keymap.del` with a `buffer` opt only deletes buffer-local mappings
  (`:h vim.keymap.del`), hence the per-buffer del of a global map fails.

## Proposed change

Pick one (both verified against the docs above):

- **Delete the globals once at startup** (top level of keymaps.lua, not per
  LspAttach): `pcall(vim.keymap.del, "n", km)` for each of the six, plus
  `pcall(vim.keymap.del, "x", "gra")`. This matches the comment's stated
  intent ("Unmap default gr*").
- Or keep the defaults and add `nowait = true` to the buffer-local `gr`
  mapping (map.txt:200-203), which removes the delay without touching the
  defaults. Note `grn`/`gra`/`gri`/`grt`/`grx` then stay reachable but the
  buffer-local `gr` fires immediately.

Either way, delete the dead per-buffer unmap loop.
