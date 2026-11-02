---
title: "retrieve aborts with an unbound variable on bash 3.2 when nothing matches"
kind: bug
component: playground
impact: low
origin: review
---
# retrieve aborts with an unbound variable on bash 3.2 when nothing matches

Found in the plan review of the archive.sh test backfill on 2026-11-02.
`archive.sh retrieve` without a pattern, when there are no archives and fzf
is missing or there is no terminal, ends with a bash error instead of a
message, when the script runs under macOS `/bin/bash` 3.2.

## Problem

Read in the code on 2026-11-02, not reproduced. In `playground/archive.sh`,
`pick_archive` prints `"${matches[@]}"` before dying when fzf cannot be used.
With no archives the array is empty, and bash 3.2 treats an empty array
expansion as unbound under `set -u`. The shebang finds Homebrew bash first,
so the error shows only when the script runs under `/bin/bash`.

## Impact

A confusing error message in a rare case; nothing is lost.

## Suggested fix

Die with "no archives" when `matches` is empty, before the fzf branch, or
expand with `${matches[@]+"${matches[@]}"}` as `helpers.bash` does.
