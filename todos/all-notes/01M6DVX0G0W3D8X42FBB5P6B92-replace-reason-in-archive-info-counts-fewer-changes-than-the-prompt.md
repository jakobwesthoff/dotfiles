---
title: "Replace reason in .archive-info counts fewer changes than the prompt"
kind: bug
component: playground
impact: low
origin: review
---
# Replace reason in .archive-info counts fewer changes than the prompt

Found in the plan review of the archive.sh test backfill on 2026-11-02. When
a directory collides with its archive and the user answers "replace", the
prompt and the provenance record written into the new archive disagree on
how many paths changed.

## Problem

Read in the code on 2026-11-02, not reproduced. In `playground/archive.sh`,
`replace_cost` counts "changed" as `CMP_CONTENT + CMP_META` (content and
metadata differences). The reason `handle_collision` passes to `archive_dir`
for a replace says `changed $CMP_CONTENT`, content differences only.

## Impact

`.archive-info` understates what a replace discarded when only metadata
(mtime, mode, owner) differed.

## Suggested fix

Count changes the same way in both places, or name both figures in the
reason ("content changed N, metadata changed M").
