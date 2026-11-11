---
title: "Drop the sesh cache refresh hooks once sesh lists tmux sessions live"
kind: chore
component: config
status: blocked
origin: implementation
tags: [tooling]
---
# Drop the sesh cache refresh hooks once sesh lists tmux sessions live

The tmux config runs `sesh cache refresh` from three tmux hooks and from
the picker's ctrl-d kill binding, so that sesh's session-list cache sees
tmux sessions created, closed or renamed outside `sesh connect`. A sesh
change submitted upstream (branch `live-tmux-sessions-in-cached-list` in
the fork at `~/Development/github/jakobwesthoff/sesh`, 2026-11-11) stops
caching tmux sessions: they are read live on every `sesh list`, and only
zoxide and tmuxinator stay cached. Once a sesh release with that change
is installed, the hooks have nothing left to refresh and only cost a
zoxide fetch on every session event.

## What to change

- `.tmux.conf`: remove the three `set-hook -g session-created|closed|renamed
  'run-shell -b "sesh cache refresh"'` lines and the comment block above
  them.
- `.tmux.conf`: in the `bind-key "s"` picker, drop `; sesh cache refresh`
  from the ctrl-d binding, so it reads
  `execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)`.
- `.config/sesh/sesh.toml`: rewrite the comment that names the three paths
  keeping the cache current (connect, hooks, ctrl-d) and the 5 s
  stale-while-revalidate note, so it says the cache holds only zoxide and
  tmuxinator.

## Done when

`sesh --version` reports a release that contains the change (its cache
file is `~/.cache/sesh/sessions.v2.gob`), the edits above are made, and
the prefix-s picker shows a session created with plain `tmux new-session
-d` and drops one killed with ctrl-d without any hook. The old
`~/.cache/sesh/sessions.gob` can be deleted then.

## Relations

- Blocked by: a sesh release (Homebrew) that includes the upstream PR
  "List tmux sessions live when the cache is enabled"
  (https://github.com/joshmedeski/sesh/pull/539)
