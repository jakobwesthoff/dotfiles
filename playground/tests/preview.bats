#!/usr/bin/env bats

load helpers
load preview-helpers

# __preview is what fzf runs for the highlighted archive during retrieve.

setup() {
  setup_root
}

# An archive of the directory "old" with its listing, as an archive run writes it.
archive_old() {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
}

# =========================================================
# With a listing
# =========================================================

@test "the member list is the stored listing, not the archive's members" {
  archive_old
  write_sentinel_listing old.tar.xz 6

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]

  [[ "$output" == *"LISTED 001"* ]]
  [[ "$output" != *"old/a.txt"* ]]
}

@test "the date and size line comes first" {
  archive_old

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]

  [[ "${lines[0]}" == "$(date -r "$ARCHIVE/old.tar.xz" +%Y-%m-%d)"* ]]
}

@test "the preview lists 200 lines of the listing and no more" {
  archive_old
  write_sentinel_listing old.tar.xz 250

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]

  # Line 1 is the directory and line 2 the record, so 200 lines end at 198.
  [[ "$output" == *"LISTED 198"* ]]
  [[ "$output" != *"LISTED 199"* ]]
}

@test "a listing larger than a pipe buffer still shows the record and its first lines" {
  archive_old
  write_sentinel_listing old.tar.xz 3000

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]

  [[ "$output" == *"directory: old"* ]]
  [[ "$output" == *"LISTED 198"* ]]
}

@test "the record is read from the archive by name and nothing else is read" {
  archive_old
  stub_gtar_logging_calls

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]
  [[ "$output" == *"directory: old"* ]]

  [ "$(wc -l < "$GTAR_CALLS" | tr -d ' ')" -eq 1 ]
  grep -q -- '-xJOf' "$GTAR_CALLS"
}

@test "an owner or group name with a space does not hide the record" {
  archive_old
  write_sentinel_listing old.tar.xz 6 "user/Domain Users"

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]

  [[ "$output" == *"directory: old"* ]]
  [[ "$output" == *"LISTED 001"* ]]
}

@test "an archive whose listing has no record is not searched for one" {
  make_unlisted_archive proj-a
  run_archive reindex
  [ "$status" -eq 0 ]
  stub_gtar_logging_calls

  run_archive __preview proj-a.tar.xz
  [ "$status" -eq 0 ]

  [[ "$output" == *"(no .archive-info)"* ]]
  [[ "$output" == *"proj-a/a.txt"* ]]
  [ ! -s "$GTAR_CALLS" ]
}

# =========================================================
# Without a listing
# =========================================================

@test "an archive without a listing shows a line naming reindex" {
  archive_old
  rm "$ARCHIVE/index/old.tar.xz.lst"

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]

  [[ "$output" == *"(no listing; archive.sh reindex writes it)"* ]]
  [[ "$output" != *"old/a.txt"* ]]
  [[ "$output" != *"directory: old"* ]]
}

@test "an archive without a listing is not read" {
  archive_old
  rm "$ARCHIVE/index/old.tar.xz.lst"
  stub_gtar_logging_calls

  run_archive __preview old.tar.xz
  [ "$status" -eq 0 ]

  [ ! -s "$GTAR_CALLS" ]
}
