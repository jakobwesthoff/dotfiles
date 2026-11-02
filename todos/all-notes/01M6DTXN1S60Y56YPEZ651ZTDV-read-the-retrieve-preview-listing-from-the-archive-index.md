---
title: "Read the retrieve preview listing from the archive index"
kind: improvement
component: playground
origin: implementation
tags: [performance, ux]
---
# Read the retrieve preview listing from the archive index

The fzf picker of `archive.sh retrieve` shows a preview of the highlighted
archive. It builds the member list by decompressing the archive until 200
members are listed, or to its end when it has fewer, and repeats that for
every archive the cursor passes. On an archive with large files near the
start, that means decompressing gigabytes for one preview. Every archive now has a member listing at
`archive/index/<archive file name>.lst` (`fc63da6`, `0f6a18e`), so the
listing part of the preview can be read from there at once. Noticed while
adding the index on 2026-11-02.

## Goal

`playground/archive.sh`, `cmd_preview`, prints the members from the
archive's `.lst` file when it exists. Without a listing (an archive written
before the index and not yet reindexed, or one whose listing failed) it
falls back to reading the archive, as it does today.

## Proposal

- Use `listing_path` to find the listing, and print its first 200 lines as
  the preview does today with `gtar -tvJf | gsed 200q`.
- Keep the date and size line.
- The `.archive-info` provenance record is still read from the archive with
  `gtar -xJOf --occurrence`, which stops at the first match. It sorts ahead
  of nearly every other member, so this read stays short.

## Open questions

- Listings print times in UTC, the fallback prints them in local time. Say
  so in the preview, or convert one of them so both look the same.
- Whether reading `.archive-info` is still slow on the largest archives,
  where the first xz block alone is large. Measure on a large fixture
  before deciding whether it needs its own cache.

## Done when

- The preview of an archive with a listing does not decompress the archive
  for the member list, shown by a test.
- An archive without a listing still previews its members, shown by a test.
