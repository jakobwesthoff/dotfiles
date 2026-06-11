# Try the experimental ui2 message/cmdline UI (pairs with cmdheight=0)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). Experiment todo — opt-in trial, easy
to revert.

## What it is

The redesign of the core message + cmdline presentation layer. It was
introduced as experimental `vim._extui` in 0.12
(`runtime/doc/news-0.12.txt:399-405`); in the running 0.13-dev build it
lives at `vim._core.ui2` (the `vim._extui` module name no longer
exists — verified by a failed `require` probe). Enable with:

```lua
require("vim._core.ui2").enable({})
```

Key facts from the module doc (`runtime/lua/vim/_core/ui2.lua:1-50`):

- Four dedicated windows/buffers: `cmd` (cmdline; also 'showcmd',
  'showmode', 'ruler', messages by default), `msg` (ephemeral message
  window, "useful for 'cmdheight' == 0"), `pager` (`:messages` and
  never-collapsed messages), `dialog` (modal prompts).
- `msg.targets` routes message kinds to cmdline/msg-window/pager.
- Replaces the legacy hit-enter prompt: long messages are "collapsed"
  with a `[+x]` spill indicator; `g<` or ENTER expands.
- Each special buffer gets a `filetype` (`cmd`, `msg`, …) so FileType
  autocmds can style them.

## Why it's relevant to this config specifically

- `options.lua:65` sets `cmdheight = 0`. The running build's option doc
  states: "WARNING: `cmdheight=0` is EXPERIMENTAL. Works better with
  `ui2` enabled" (`runtime/lua/vim/_meta/options.lua:968`).
- fidget currently has `override_vim_notify = true` (lsp.lua:36) to get
  notifications out of the message area; ui2's `msg` window addresses
  the same pain point natively. With ui2 enabled, evaluate whether
  fidget should keep owning vim.notify or drop back to progress-only.

## Caveats

- Explicitly experimental ("WARNING: This is an experimental feature",
  ui2.lua:2-4); the module path itself already changed once
  (`vim._extui` → `vim._core.ui2`), so pin expectations accordingly and
  wrap the enable call in `pcall`.
- Interactions to test: fzf-lua floating windows, fidget notifications,
  `vim.o.winborder = "rounded"` (whether ui2 windows pick it up), tmux
  rendering, `inccommand = "split"` preview.

## Suggested trial

```lua
-- in setup.lua or an experiments module; safe to remove anytime
pcall(function()
  require("vim._core.ui2").enable({
    msg = { targets = "msg" },  -- route messages to the ephemeral window
  })
end)
```

Run with it for a few days; the success criteria are: no hit-enter
prompts, readable multi-line messages despite cmdheight=0, no rendering
artifacts in tmux.

## Basis

All facts from the runtime source/doc of the build in use, read
2026-06-11; module rename verified by headless probes (`vim._extui`
require fails, `vim._core.ui2` exists with documented `enable()`).
