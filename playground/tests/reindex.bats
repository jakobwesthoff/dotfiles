#!/usr/bin/env bats

load helpers

setup() {
  setup_root
}

teardown() {
  restore_permissions
}

@test "reindex writes a listing for every archive that has none" {
  make_unlisted_archive proj-a
  make_unlisted_archive "dir with space"
  make_unlisted_archive proj-a.2026-01-01

  run_archive reindex
  [ "$status" -eq 0 ]
  [[ "$output" == *"indexed        proj-a.tar.xz"* ]]
  [[ "$output" == *"indexed        dir with space.tar.xz"* ]]
  [[ "$output" == *"indexed        proj-a.2026-01-01.tar.xz"* ]]
  [[ "$output" == *"indexed: 3   failed: 0   up to date: 0   removed stale: 0"* ]]

  [ -s "$ARCHIVE/index/proj-a.tar.xz.lst" ]
  [ -s "$ARCHIVE/index/dir with space.tar.xz.lst" ]
  [ -s "$ARCHIVE/index/proj-a.2026-01-01.tar.xz.lst" ]
}

@test "a listing written by reindex matches the format of the archive run" {
  make_unlisted_archive proj-a
  make_dir proj-b 30

  run_archive reindex
  [ "$status" -eq 0 ]
  run_archive
  [ "$status" -eq 0 ]

  # The same directory, archived by the script and by hand, lists alike.
  listing_oracle "$ARCHIVE/proj-a.tar.xz" > "$BATS_TEST_TMPDIR/expected"
  cmp "$BATS_TEST_TMPDIR/expected" "$ARCHIVE/index/proj-a.tar.xz.lst"
  listing_oracle "$ARCHIVE/proj-b.tar.xz" > "$BATS_TEST_TMPDIR/expected"
  cmp "$BATS_TEST_TMPDIR/expected" "$ARCHIVE/index/proj-b.tar.xz.lst"
}

@test "reindex leaves an existing listing alone" {
  make_unlisted_archive proj-a
  mkdir -p "$ARCHIVE/index"
  printf 'sentinel\n' > "$ARCHIVE/index/proj-a.tar.xz.lst"

  run_archive reindex
  [ "$status" -eq 0 ]
  [[ "$output" == *"indexed: 0   failed: 0   up to date: 1   removed stale: 0"* ]]

  [ "$(cat "$ARCHIVE/index/proj-a.tar.xz.lst")" = "sentinel" ]
}

@test "reindex deletes the listing of an archive that is gone" {
  mkdir -p "$ARCHIVE/index"
  printf 'sentinel\n' > "$ARCHIVE/index/gone.tar.xz.lst"

  run_archive reindex
  [ "$status" -eq 0 ]
  [[ "$output" == *"removing       gone.tar.xz.lst (archive gone)"* ]]
  [[ "$output" == *"removed stale: 1"* ]]

  [ ! -e "$ARCHIVE/index/gone.tar.xz.lst" ]
}

@test "reindex goes on after an archive it cannot read" {
  make_unlisted_archive proj-a
  printf 'not an archive\n' > "$ARCHIVE/broken.tar.xz"

  run_archive reindex
  [ "$status" -eq 1 ]
  [[ "$output" == *"cannot list broken.tar.xz; no listing written"* ]]
  [[ "$output" == *"indexed: 1   failed: 1   up to date: 0   removed stale: 0"* ]]

  [ -s "$ARCHIVE/index/proj-a.tar.xz.lst" ]
  [ ! -e "$ARCHIVE/index/broken.tar.xz.lst" ]
  [ ! -e "$ARCHIVE/index/broken.tar.xz.lst.part" ]
}

@test "reindex creates the index directory and accepts an empty folder" {
  run_archive reindex
  [ "$status" -eq 0 ]
  [[ "$output" == *"indexed: 0   failed: 0   up to date: 0   removed stale: 0"* ]]

  [ -d "$ARCHIVE/index" ]
}

@test "reindex removes part files left by an interrupted run" {
  mkdir -p "$ARCHIVE/index"
  printf 'half\n' > "$ARCHIVE/index/proj-a.tar.xz.lst.part"

  run_archive reindex
  [ "$status" -eq 0 ]

  [ ! -e "$ARCHIVE/index/proj-a.tar.xz.lst.part" ]
}

@test "reindex keeps going when a stale listing cannot be deleted" {
  make_unlisted_archive proj-a
  mkdir -p "$ARCHIVE/index"
  printf 'sentinel\n' > "$ARCHIVE/index/gone.tar.xz.lst"
  chmod 555 "$ARCHIVE/index"

  run_archive reindex
  [[ "$output" == *"could not delete listing gone.tar.xz.lst"* ]]
  [[ "$output" == *"removed stale: 0"* ]]
}

@test "reindex takes no arguments" {
  run_archive reindex extra
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: archive.sh"* ]]
}

@test "reindex has no dry run" {
  run_archive --dry-run reindex
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: archive.sh"* ]]
}

@test "the usage text names reindex" {
  run_archive --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"archive.sh reindex"* ]]
}
