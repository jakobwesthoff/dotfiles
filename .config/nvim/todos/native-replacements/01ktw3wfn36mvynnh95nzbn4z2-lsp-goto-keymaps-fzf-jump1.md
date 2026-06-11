# Replace custom gd/gI/gD logic with plain fzf-lua calls (jump1 is the default)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/keymaps.lua:50-132` implements, per the comment at lines
42-47, "if there is only one match ... directly go there. Otherwise we
open fzf-lua" for gd (definitions), gI (implementations), and gD
(declarations), via hand-rolled `vim.lsp.buf_request` calls (~80 lines).

This is exactly fzf-lua's built-in default behavior. The installed
fzf-lua defines for all LSP pickers:

```lua
-- ~/.local/share/nvim/lazy/fzf-lua/lua/fzf-lua/defaults.lua:1485-1486
jump1            = true,
jump1_action     = actions.file_edit,
```

documented as "Automatically jump to the location when there's only a
single result" (defaults.lua:1461-1462). So
`require("fzf-lua").lsp_definitions()` alone already jumps directly on
a single result and opens the picker otherwise — the same pattern the
config already uses for `gr` (keymaps.lua:77-79).

## Bugs in the custom code that disappear with the refactor

All verified against the running build's runtime
(`/opt/homebrew/Cellar/neovim/HEAD-e508aa0/share/nvim/runtime`):

1. **Dead unwrap.** LSP handlers receive `(err, result, ctx)` with the
   result already unwrapped (`doc/lsp.txt:373-376`). The
   `if type(result) == "table" and result.result` branch never fires.
2. **Errors ignored.** `err` is discarded; a server error surfaces as
   the misleading "No definition found".
3. **Single-`Location` shape not handled.** Servers may return one
   `Location` instead of `Location[]`; then `#items == 0` and the code
   opens the picker instead of jumping.
4. **`vim.lsp.buf.definition(params)` misuse.** That function takes an
   opts table (`vim.lsp.LocationOpts`), not position params
   (`lua/vim/lsp/buf.lua:296-304`). The params are treated as empty
   opts and a *second* request fires at the *current* cursor position —
   a race if the cursor moved since the first request.
5. **Per-client double fire.** `vim.lsp.buf_request` invokes the handler
   once per supporting client (`lua/vim/lsp.lua:1257-1269`), so
   multi-client buffers can jump or open the picker twice.
6. **Deprecation: `make_position_params()` without `position_encoding`**
   (keymaps.lua:51, :83, :117) warns on this build
   (`lua/vim/lsp/util.lua:2054-2063`) and conceptually sends one
   client's encoding to all clients.
7. **Deprecation: `client.supports_method` dot-call** (keymaps.lua:106),
   removal target 0.13 (`lua/vim/lsp/client.lua:253`).

## Fix

```lua
-- [G]oto [D]efinition(s)
vim.keymap.set("n", "gd", function() require("fzf-lua").lsp_definitions() end,
  { buffer = event.buf, desc = "[G]oto [D]efinition(s)" })
-- [G]oto [I]mplementation(s)
vim.keymap.set("n", "gI", function() require("fzf-lua").lsp_implementations() end,
  { buffer = event.buf, desc = "[G]oto [I]mplementation(s)" })
-- [G]oto [D]eclaration
vim.keymap.set("n", "gD", function() require("fzf-lua").lsp_declarations() end,
  { buffer = event.buf, desc = "[G]oto [D]eclaration" })
```

(`buffer = event.buf` per
`todos/bugs/*-lsp-attach-keymaps-not-buffer-local.md`.)

Behavioral notes to check when implementing:

- The current gD code pre-checks `textDocument/declaration` capability
  and notifies "not supported". What fzf-lua does on an unsupported
  method was **not verified** during review; test with a server lacking
  declaration support (e.g. lua_ls) and, if the resulting UX is too
  quiet, keep a one-line guard using
  `client:supports_method("textDocument/declaration", 0)`.
- "No definition found"-style empty-result notifications: fzf-lua shows
  its own messaging for empty LSP results; verify it is acceptable.
- `jump1_action = actions.file_edit` edits in the current window — same
  as the old `vim.lsp.buf.definition` behavior.

## Evidence / basis

- Installed fzf-lua source: `defaults.lua:1461-1462, :1485-1486`
  (option, default, doc comment).
- Runtime sources cited inline above (read during review).
- Existing `gr` mapping (keymaps.lua:77-79) already relies on this
  fzf-lua behavior, so the UX is proven in this config.
