---
title: "Failed compression leaves a provenance record in the original directory"
kind: bug
component: playground
impact: low
origin: review
---
# Failed compression leaves a provenance record in the original directory

Found in the plan review of the archive.sh test backfill on 2026-11-02.
`playground/archive.sh`, `archive_dir`, appends the `.archive-info` record to
the directory before it compresses and validates. When either step fails the
script dies and the record stays in the original, describing an archive that
was never written.

## Problem

Read in the code on 2026-11-02, not reproduced. `write_archive_info` runs
first in `archive_dir`; the `die` calls after a failed compression or
validation leave the directory with the new record. The next run appends
another record, so a directory that failed twice carries two entries for
archives that do not exist.

## Impact

The provenance chain in `.archive-info` gains entries for archives that
were never written.

## Suggested fix

Keep the previous record (or its absence) and restore it before dying, or
write the record into the archive stream without touching the directory
until the archive is in place.
