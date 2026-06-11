# Replace deprecated `client.supports_method(...)` dot-calls (removal target 0.13)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

Three call sites use the deprecated dot-call form on LSP client objects:

- `lua/mrjakob/plugins/lsp.lua:105`:
  `client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)`
- `lua/mrjakob/plugins/lsp.lua:128`:
  `client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)`
- `lua/mrjakob/keymaps.lua:106`:
  `client.supports_method("textDocument/declaration")`

On the running build (NVIM v0.13.0-dev-2756) the dot-call goes through a
compatibility wrapper that fires
`vim.deprecate('client.supports_method', 'client:supports_method', '0.13')`
(`runtime/lua/vim/lsp/client.lua:245-256`, wrapper installed at `:493`).
The recorded removal target is **0.13 — the version currently in use**;
the wrapper still exists in this dev build but is scheduled for
deletion, at which point these three lines hard-break.

This warning fires in practice: booting this config headless with a Lua
file printed "client.supports_method is deprecated" during review.

## Evidence / basis

- Config read at the three lines above.
- Runtime source: `lua/vim/lsp/client.lua:245-256` (method_wrapper +
  vim.deprecate call), `:493` (supports_method wrapped), `:1190`
  (`function Client:supports_method(method, bufnr)` — note the optional
  `bufnr` parameter).
- Live observation: deprecation message printed on headless boot with
  this config (2026-06-11).

## Fix

Switch to colon calls, and pass the buffer for buffer-accurate results:

```lua
-- lsp.lua:105
if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
-- lsp.lua:128
if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
```

The `keymaps.lua:106` site sits inside the custom gD logic that is
slated for removal by the fzf-lua `jump1` refactor
(`todos/native-replacements/*-lsp-goto-keymaps-fzf-jump1.md`). If that
refactor lands first, only the two lsp.lua sites remain; if a
capability pre-check for gD is kept, use
`client:supports_method("textDocument/declaration", 0)`.
