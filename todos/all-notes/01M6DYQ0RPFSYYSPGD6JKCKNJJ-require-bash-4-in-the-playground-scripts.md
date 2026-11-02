---
title: "Require bash 4 in the playground scripts"
kind: bug
component: playground
origin: review
---
# Require bash 4 in the playground scripts

Found in the plan review of the timecapsule-sync bash 3.2 fix on 2026-11-02.
Under macOS `/bin/bash` 3.2, a script with `set -eu` and an EXIT trap exits 0
after an unbound-variable error, and `$?` inside the trap is already 0, so
the trap cannot pass the real status on. Homebrew bash exits 1.
`playground/archive.sh` and `playground/timecapsule-sync.sh` both run with
`set -euo pipefail` and set EXIT traps, so under `/bin/bash` an aborted run
can look successful to cron, launchd or a calling script.

## Problem

Reproduced on 2026-11-02:
`/bin/bash -c 'set -eu; trap "true" EXIT; echo "$nope"'; echo $?` prints 0,
the same without the trap prints 1, and Homebrew bash prints 1 with the trap.

## Decisions

- 2026-11-02, user: both scripts require bash 4 or newer instead of keeping
  bash 3.2 support.
- 2026-11-02, user: under bash 3.2 the scripts stop with a message; they do
  not re-run themselves under a newer bash. A scheduled run calls Homebrew
  bash explicitly.

## Suggested fix

Both scripts check `BASH_VERSINFO` before anything else and stop with a
message naming the bash they run under and how to get a newer one. The test
runs under `/bin/bash` 3.2 (`ARCHIVE_BASH`, `SYNC_BASH`) change to test that
refusal, and workarounds that exist only for bash 3.2 can go.
