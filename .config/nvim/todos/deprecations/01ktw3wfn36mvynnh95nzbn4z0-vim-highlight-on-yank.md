# Replace deprecated `vim.highlight.on_yank()` with `vim.hl.on_yank()`

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/autocmds.lua:6` calls `vim.highlight.on_yank()` in the
TextYankPost autocmd. On the running build
(NVIM v0.13.0-dev-2756+ge508aa0fa8-Homebrew), `vim.highlight` is no
longer a real module but a deprecation shim:

- `runtime/lua/vim/_core/editor.lua:1313`:
  `vim.highlight = vim._defer_deprecated_module('vim.highlight', 'vim.hl')`
- `runtime/lua/vim/_core/shared.lua:1413-1430`: every index or call on
  the shim fires `vim.deprecate('vim.highlight', 'vim.hl', '2.0.0')`
  before delegating to `vim.hl`.

So every yank currently triggers a deprecation code path. The removal
target recorded in the shim is "2.0.0" (far out), but the replacement
is a one-word change.

## Evidence / basis

- Config read: `autocmds.lua:1-9`.
- Runtime source as cited above (read during review).
- Headless probe on the running build: `type(vim.hl.on_yank)` →
  `function`.

## Fix

```lua
callback = function()
  vim.hl.on_yank()
end,
```

No behavioral difference; `vim.hl.on_yank` is the same function the
shim delegates to.
