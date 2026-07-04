# .tmux.conf cleanup: duplicated prefix block, inert ghostty Tc override

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.tmux.conf

Two small, verified cleanups in the same file.

## 1. Prefix setup is configured twice

Lines 9-12:

```
# Change the prefix key to C-a
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

Lines 34-37 repeat the identical three commands:

```
# unbind the prefix and bind it to Ctrl-a like screen
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

Harmless but redundant; delete one of the two blocks.

## 2. `",ghostty:Tc"` terminal-override never matches

Line 3:

```
set-option -ga terminal-overrides ",ghostty:Tc"
```

- Ghostty sets `TERM=xterm-ghostty` (installed Ghostty 1.3.1,
  `+show-config` default `term = xterm-ghostty`; live tmux session on
  2026-07-04: `#{client_termname}` → `xterm-ghostty`).
- tmux matches terminal-overrides entries against the terminal type with
  glob patterns (tmux 3.7 man page, terminal-overrides: "a terminal type
  pattern (matched using glob(7) patterns)"). The pattern `ghostty` does
  not glob-match `xterm-ghostty`, so the entry never applies.
- It is also unnecessary: the xterm-ghostty terminfo shipped by Ghostty
  already advertises truecolor (`infocmp -x xterm-ghostty` contains `Tc`
  and `setrgbf`), and the live session confirms detection:
  `#{client_termfeatures}` → `bpaste,ccolour,clipboard,cstyle,focus,RGB,title`.

Delete line 3. The `",xterm-256color:Tc"` override on line 2 still earns
its keep for contexts where the outer TERM is xterm-256color (e.g. running
tmux on a remote host reached with a downgraded TERM).
