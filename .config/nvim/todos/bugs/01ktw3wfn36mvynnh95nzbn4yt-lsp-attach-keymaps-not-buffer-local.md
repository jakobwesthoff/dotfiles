# Make LspAttach-registered keymaps buffer-local (and fix inlay-hint toggle scope)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

Two locations register keymaps inside `LspAttach` callbacks without
`buffer = event.buf`, making them global:

1. `lua/mrjakob/keymaps.lua:35-147` — the comment at lines 33-34 says
   "Only register for buffers, where the LSP actually attached", but
   none of the `vim.keymap.set` calls in the callback pass a `buffer`
   key. After the first LSP attach in a session, `gd`, `gr`, `gI`, `gD`,
   `<leader>D`, `<leader>cr`, `<leader>ca` exist globally — in non-LSP
   buffers too — and persist after detach. The callback ignores its
   `event` argument entirely (signature is `callback = function()`).

2. `lua/mrjakob/plugins/lsp.lua:128-132` — the inlay-hint toggle
   `<leader>uh` is registered globally on every attach of a
   hint-capable client. Additionally the toggle is internally
   inconsistent: it *reads* per-buffer state
   (`vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })`) but *writes*
   globally (`vim.lsp.inlay_hint.enable(...)` with no filter applies to
   all buffers — runtime `lua/vim/lsp/inlay_hint.lua:407-421`). The
   `event.buf` captured in the closure is the buffer that happened to
   attach when the global mapping was last overwritten, not the buffer
   the user presses the key in.

## Evidence / basis

- Config read: `keymaps.lua:35-147` (no `buffer` keys), `lsp.lua:128-132`.
- Runtime source of the running build
  (`/opt/homebrew/Cellar/neovim/HEAD-e508aa0/share/nvim/runtime`):
  `lua/vim/lsp/inlay_hint.lua:407-421` (`enable()` with nil filter =
  global).
- Verified by the core-config and LSP review agents independently.

## Fix

In `keymaps.lua`, accept the event and scope every mapping:

```lua
callback = function(event)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
  end
  -- use map(...) for gd / gr / gI / gD / <leader>D / <leader>cr / <leader>ca
end
```

In `lsp.lua`, scope the mapping and the toggle to the keypress buffer:

```lua
vim.keymap.set("n", "<leader>uh", function()
  local buf = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(
    not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }),
    { bufnr = buf }
  )
end, { buffer = event.buf, desc = "Toggle [U]i Inlay [H]ints" })
```

(If a global toggle is actually preferred, make the read side global
instead — just don't mix scopes.)

## Interaction with other todos

The gd/gI/gD bodies are slated for replacement by fzf-lua one-liners
(see `todos/native-replacements/*-lsp-goto-keymaps-fzf-jump1.md`). Do
that refactor first; this todo then only needs to add `buffer =
event.buf` to the surviving short mappings.
