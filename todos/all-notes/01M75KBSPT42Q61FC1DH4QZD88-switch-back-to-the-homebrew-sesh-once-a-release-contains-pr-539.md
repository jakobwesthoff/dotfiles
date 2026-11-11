---
title: "Switch back to the Homebrew sesh once a release contains PR 539"
kind: chore
component: config
status: blocked
origin: implementation
tags: [tooling]
---
# Switch back to the Homebrew sesh once a release contains PR 539

`~/go/bin/sesh` is a local build of branch
`live-tmux-sessions-in-cached-list` from the fork checkout at
`~/Development/github/jakobwesthoff/sesh` (built 2026-11-11 as
`v2.34.0-14-gc13fd3c`). It lists tmux sessions live with `cache = true`,
which the tmux config relies on since it no longer runs `sesh cache
refresh` hooks. `.zprofile.d/050_go.sh` puts `~/go/bin` ahead of Homebrew,
so this build shadows the bottle. Once a sesh release contains
https://github.com/joshmedeski/sesh/pull/539, the local build is no longer
needed.

## What to change

- `brew upgrade sesh` to the release with PR 539, then delete
  `~/go/bin/sesh` so `sesh` resolves to `/opt/homebrew/bin/sesh`. Keep the
  `~/go/bin` PATH entry; gitleaks and mockery live there.
- `.config/sesh/sesh.toml`: replace the paragraph about the local build
  with the minimum sesh version that lists tmux sessions live.
- In the fork checkout, `git switch main` and sync it with `upstream`; delete
  the local and `origin` branch `live-tmux-sessions-in-cached-list` once the
  PR is merged.

## Done when

`sesh --version` reports a Homebrew release, `command -v sesh` (in a login
shell and through `tmux run-shell`) prints `/opt/homebrew/bin/sesh`, and a
session made with `tmux new-session -d` shows in `sesh list` at once.

## Relations

- Blocked by: a sesh release on Homebrew that includes
  https://github.com/joshmedeski/sesh/pull/539
