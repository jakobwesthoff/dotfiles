---
title: "Archive run treats a symlinked directory as a working directory"
kind: bug
component: playground
origin: review
---
# Archive run treats a symlinked directory as a working directory

Found in the plan review of the archive.sh bug fixes on 2026-11-02. When the
playground holds a symlink to a directory, the archive run of
`playground/archive.sh` archives the link itself, deletes the link and
writes `.archive-info` into the link's target.

## Problem

Reproduced on 2026-11-02 on a throwaway playground: a link `linked` to a
directory of old files was reported as `archiving linked`, the archive held a
single symlink member, the link was gone afterwards, and the target had a new
`.archive-info`. The `"$ROOT"/*/` glob in `cmd_archive` matches symlinks to
directories.

## Impact

The archive holds no data, the playground entry disappears, and a directory
outside the playground is modified. The target's files survive.

## Decisions

- 2026-11-02, user: symlinked directories are skipped and listed in the run
  output, like `.no-archive` directories. Nothing is written or deleted.

## Done when

- A test shows a symlinked directory is left in place, its target unchanged,
  and the run names it as skipped.
