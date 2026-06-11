# Remove the `window/showMessage` handler override (native default supersedes it)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/lsp.lua:140-157` overrides
`vim.lsp.handlers["window/showMessage"]` with the stated purpose
(comment, line 140) of "using vim.notify instead of logging to
messages". On the running build the **default** handler already does
exactly that:

- `runtime/lua/vim/lsp/handlers.lua:32-44`
  (`show_message_notification`): formats `LSP[<client>] <message>`,
  handles the client-has-shut-down case, and calls
  `vim.notify(message, log._from_lsp_level(message_type))`.
- Wired up for the notification at `handlers.lua:618-620`.
- The override is still honored at dispatch
  (`lua/vim/lsp/client.lua:645-646`), so it is active — and worse than
  the default.

The override carries an actual bug: `lsp.lua:154` selects the level via
`vim.log.levels[message_type]`. `vim.log.levels` has **string** keys
(TRACE/DEBUG/INFO/WARN/ERROR); LSP `MessageType` is numeric 1..5. The
lookup is always nil, so every non-Error server message is notified
with the default level — Warning/Info/Log severities are lost. Verified
by headless probe on this build: `vim.log.levels[1..4]` are all nil.

The only thing the override adds over the default is including the
message-type *name* in the text
(`vim.lsp.protocol.MessageType[message_type]` reverse lookup — which
does work, `protocol.lua:331-337`). The native level mapping
(`lua/vim/lsp/log.lua:226-236`) makes that redundant: fidget/notify
already render severity.

## Evidence / basis

- Config read: `lsp.lua:140-157`.
- Runtime sources cited inline (all read during review on
  NVIM v0.13.0-dev-2756).
- Headless probe: numeric indexing of `vim.log.levels` returns nil.

## Fix

Delete `lsp.lua:140-157` (the comment plus the whole handler
assignment). No replacement needed; the default handler provides the
intended behavior with correct levels.

## Verification

Trigger a server message — e.g. lua_ls emits showMessage on certain
workspace events, or use a test:
`vim.lsp.handlers` no longer contains the key, and a
`window/showMessage` notification from any server appears via
vim.notify (rendered by fidget, which has `override_vim_notify = true`
in this config) with a sensible level.
