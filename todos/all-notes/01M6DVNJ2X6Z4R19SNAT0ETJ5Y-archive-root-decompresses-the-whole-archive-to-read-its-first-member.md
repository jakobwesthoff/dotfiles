---
title: "archive_root decompresses the whole archive to read its first member"
kind: bug
component: playground
origin: review
tags: [performance]
---
# archive_root decompresses the whole archive to read its first member

Found in the plan review of the retrieve preview change on 2026-11-02.
`playground/archive.sh`, `archive_root`, is meant to stop after the first
member, and its comment says it "keeps this fast on archives of several
gigabytes". It does not stop: it reads the archive to its end.

## Problem

Measured on 2026-11-02 with a fixture of one 202 MB base64 file in a 149 MB
`.tar.xz`: `archive_root` took 0.73 s, the same as a full `xz -dc` of the
archive (0.72 s). The pipeline is `gtar -tJf | gsed -n '1{...;q}'`. The likely
cause is that gtar buffers its listing when stdout is a pipe, so the first
line reaches gsed only when gtar has read everything, and the early `q` never
cuts the decompression short. The cause is reasoned, not traced.

## Impact

Every call pays a full decompression. `cmd_retrieve` calls it once for the
picked archive, and `archives_for` calls it for every candidate archive of a
directory that comes up in an archive run. On an archive of a few gigabytes
that is tens of seconds per call.

## Suggested fix

Read the root from the archive's listing in `archive/index/` when one
exists, as the retrieve preview does. Without a listing, read only the start
of the stream, for example `xz -dc | head -c 512` and the name field of the
first tar header, or a gtar invocation whose output is not buffered. Correct
the comment either way.

## Done when

- A test shows `archive_root` returning without reading the whole archive,
  with and without a listing.
