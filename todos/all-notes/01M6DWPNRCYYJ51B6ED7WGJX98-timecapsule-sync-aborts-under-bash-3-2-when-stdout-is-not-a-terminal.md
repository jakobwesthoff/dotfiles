---
title: "timecapsule-sync aborts under bash 3.2 when stdout is not a terminal"
kind: bug
component: playground
impact: low
origin: review
---
# timecapsule-sync aborts under bash 3.2 when stdout is not a terminal

Found in the plan review of the timecapsule-sync config change on
2026-11-02. `playground/timecapsule-sync.sh`, `cmd_sync`, passes
`"${progress[@]}"` to rsync. The array stays empty when stdout is not a
terminal, and macOS `/bin/bash` 3.2 aborts on an empty array expansion under
`set -u` with an unbound-variable error, so the sync never starts.

## Problem

Read in the code on 2026-11-02, not reproduced. It needs both conditions:
the script runs under `/bin/bash` (the shebang finds Homebrew bash first in
an interactive shell), and its output is redirected, as from cron or
launchd. No schedule for the script was found on 2026-11-02.

## Impact

An unattended sync under the system bash fails before copying anything.

## Suggested fix

Expand with `${progress[@]+"${progress[@]}"}`, as
`playground/tests/helpers.bash` does, and add a test that runs the sync
under `/bin/bash` with stdout redirected and the network tools stubbed.
