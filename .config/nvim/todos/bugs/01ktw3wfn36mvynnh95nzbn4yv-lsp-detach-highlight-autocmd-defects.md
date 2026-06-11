# Fix LspDetach/document-highlight autocmd structure in lsp.lua

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/lsp.lua:99-134` (the `kickstart-lsp-attach`
autocmd) sets up cursor-hold document highlighting plus an LspDetach
cleanup. The structure has four defects:

1. **Global detach handler recreated per attach.** The LspDetach
   autocmd (lsp.lua:119-125) is created inside the LspAttach callback
   with `nvim_create_augroup("kickstart-lsp-detach", { clear = true })`
   and has no `buffer` key. Every attach wipes the group and re-adds one
   identical *global* handler. It happens not to lose per-buffer state
   (there is none), but the code reads as buffer-scoped and isn't.

2. **Clears highlights while another capable client is still attached.**
   The handler fires for *any* client detaching from *any* buffer and
   unconditionally runs
   `vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })`.
   Realistic case in this config: a `Cargo.toml` buffer has both taplo
   (via mason) and the in-process crates.nvim LSP (`crates.lua:8-9`
   enables `lsp.enabled`); when one detaches, highlighting dies for the
   survivor.

3. **`clear_references()` targets the wrong buffer.**
   `vim.lsp.buf.clear_references()` operates on the *current* buffer
   (runtime `lua/vim/lsp/buf.lua:1112-1115`), not `event2.buf`.

4. **Duplicate CursorHold callbacks with two capable clients.** The
   CursorHold/CursorMoved autocmds (lsp.lua:107-117, group created with
   `clear = false`) are added once per attaching highlight-capable
   client, so a buffer with two such clients gets duplicate
   `document_highlight` requests per hold.

## Evidence / basis

- Config read: `lsp.lua:99-134`, `crates.lua:8-9`.
- Runtime of the running build: `nvim_create_augroup` `clear` semantics
  (`doc/api.txt:2094-2096`), confirmed by a headless reproduction during
  review (autocmd count drops to 0 after group re-creation with
  `clear = true`); `lua/vim/lsp/buf.lua:1112-1115`
  ("Removes document highlights from current buffer").
- This structure is inherited from kickstart.nvim (group names
  `kickstart-lsp-attach`/`-highlight`/`-detach`).

## Fix

Restructure so that:

- The LspDetach autocmd is created **once**, outside the LspAttach
  callback, in its own group created a single time.
- In the detach handler, only clear when no *remaining* client for
  `event2.buf` supports documentHighlight:

```lua
vim.api.nvim_create_autocmd("LspDetach", {
  group = vim.api.nvim_create_augroup("mrjakob-lsp-detach", {}),
  callback = function(event2)
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = event2.buf })) do
      if c.id ~= event2.data.client_id
        and c:supports_method("textDocument/documentHighlight", event2.buf) then
        return
      end
    end
    vim.lsp.util.buf_clear_references(event2.buf)
    vim.api.nvim_clear_autocmds({ group = "mrjakob-lsp-highlight", buffer = event2.buf })
  end,
})
```

- Guard against duplicate registration in the attach path, e.g. clear
  buffer-scoped autocmds in the highlight group before adding, or set a
  `vim.b[event.buf]` flag.
- Use `client:supports_method(...)` (colon call) throughout — the
  dot-call is deprecated with removal target 0.13 (see
  `todos/deprecations/*-client-supports-method-colon-call.md`).

`vim.lsp.util.buf_clear_references(bufnr)` clears the given buffer's
references (it is the buffer-parameterized primitive underlying
`vim.lsp.buf.clear_references`); verify its exact name/signature against
the runtime when implementing.

## Verification

Open `Cargo.toml` (taplo + crates LSP both attach), `:LspStop` one of
them, and confirm cursor-hold highlighting still works for the other.
