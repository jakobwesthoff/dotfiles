# Replace manual OSC 52 yank autocmd with native clipboard support

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/autocmds.lua:11-34` hand-emits an OSC 52 escape sequence on
every TextYankPost into the `+`/`*` registers, via
`vim.api.nvim_chan_send(2, osc)`. Neovim has native OSC 52 support that
covers this better:

- The TUI **auto-detects** OSC 52 and uses it as the clipboard provider
  when no clipboard tool is found and `'clipboard'` is unset
  (`runtime/doc/provider.txt:271-280` on the running build).
- It can be **forced** regardless of available tools with
  `vim.g.clipboard = 'osc52'`
  (`runtime/autoload/provider/clipboard.vim:189-191, 260-263`), backed
  by the `vim.ui.clipboard.osc52` module (verified loadable by headless
  probe on this build).

The manual implementation is strictly worse than the native provider:

- Only fires on yank/delete events into `+`/`*`; misses other register
  writes (e.g. `:let @+ = ...`).
- Loses the register type: `table.concat(event.regcontents, "\n")`
  flattens linewise yanks; a paste on the receiving side loses
  linewise-ness.
- Hardcodes channel 2. That is technically `v:stderr` ("channel-id of
  stderr ... is always 2", `runtime/doc/vvars.txt:626-630`), valid in a
  TUI, but emits escape garbage in embedded/GUI contexts (firenvim,
  GUI frontends) where stderr is not a terminal.
- No paste support (native provider handles paste via OSC 52 queries
  where the terminal allows it).

Also: the explanatory comment block is duplicated nearly verbatim
(autocmds.lua:11-14 and :16-20).

## The current setup's stated intent

The comment says the manual sequence runs "in addition to Neovim's
auto-detected native clipboard provider" — i.e. on this macOS machine
pbcopy handles the local clipboard and the OSC 52 escape additionally
updates the terminal-side clipboard (useful over SSH from elsewhere).
Decide which behavior is actually wanted:

- **Local-first (pbcopy) with OSC 52 only over SSH:** delete the
  autocmd entirely. Native auto-detection already picks OSC 52 when
  running over SSH without clipboard tools
  (`provider.txt:271-280`). Caveat from the same doc section:
  auto-detection can be inhibited inside tmux depending on tmux's
  `set-clipboard` setting — this config's owner uses tmux, so verify
  there (`runtime/doc/provider.txt:279-280`).
- **OSC 52 always:** delete the autocmd and set
  `vim.g.clipboard = 'osc52'`. Then pbcopy is bypassed and every `+`/`*`
  access goes through OSC 52 (including paste, terminal permitting).
- **Genuinely both at once** (pbcopy locally *and* OSC 52 escape per
  yank): that dual behavior is the one thing the native provider does
  not do; keeping a (fixed) manual autocmd is then legitimate. If kept:
  guard on `vim.fn.has("ttyout")`/channel validity, preserve regtype is
  impossible via raw OSC 52 (inherent to the protocol), and deduplicate
  the comment block.

## Evidence / basis

- Config read: `autocmds.lua:11-34`.
- Runtime of the running build: `doc/provider.txt:271-280`,
  `autoload/provider/clipboard.vim:189-191, 260-263`,
  `doc/vvars.txt:626-630`.
- Headless probe: `require("vim.ui.clipboard.osc52")` loads on this
  build.

## Suggested resolution

Test option 1 (plain deletion) first in the real environments this
matters in — local iTerm/WezTerm+tmux and an SSH session — and only
fall back to `vim.g.clipboard = 'osc52'` or a fixed manual autocmd if
the auto-detection doesn't cover the actual workflow.
