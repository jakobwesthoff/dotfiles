#!/usr/bin/env bats

load helpers

setup() {
  setup_root
}

# =========================================================
# Archiving
# =========================================================

@test "an aged-out directory is archived and its original removed" {
  make_dir old 30

  run_archive
  [ "$status" -eq 0 ]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ROOT/old" ]
  members="$(gtar -tJf "$ARCHIVE/old.tar.xz")"
  [[ "$members" == *"old/a.txt"* ]]
  [[ "$members" == *"old/sub/b.txt"* ]]
  [[ "$members" == *"old/.archive-info"* ]]
}

@test "a directory with a recent file is left alone" {
  make_dir young 1

  run_archive
  [ "$status" -eq 0 ]

  [ -d "$ROOT/young" ]
  [ ! -e "$ARCHIVE/young.tar.xz" ]
}

@test "a dry run writes and deletes nothing" {
  make_dir old 30

  run_archive --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would archive  old"* ]]

  [ -d "$ROOT/old" ]
  [ -z "$(ls -A "$ARCHIVE")" ]
}

@test "a directory that holds no files is removed" {
  mkdir -p "$ROOT/hollow/skeleton"

  run_archive
  [ "$status" -eq 0 ]

  [ ! -e "$ROOT/hollow" ]
  [ -z "$(ls -A "$ARCHIVE")" ]
}

@test "a directory inside archive/ is moved back to the playground" {
  mkdir -p "$ARCHIVE/stray"
  printf 'x\n' > "$ARCHIVE/stray/f"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"restoring      stray"* ]]

  [ -f "$ROOT/stray/f" ]
  [ ! -e "$ARCHIVE/stray" ]
}

@test "archiving dies and keeps the original when the entry count differs" {
  make_dir old 30
  stub_gtar_dropping_a_listing_line

  run_archive
  [ "$status" -ne 0 ]
  [[ "$output" == *"entry count mismatch for old"* ]]

  [ -d "$ROOT/old" ]
  [ ! -e "$ARCHIVE/old.tar.xz" ]
}

# =========================================================
# Listing and retrieving
# =========================================================

@test "list prints the archives whose name contains the pattern" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]

  run_archive list ol
  [ "$status" -eq 0 ]
  [[ "$output" == *"old.tar.xz"* ]]
}

@test "retrieve restores the directory and deletes the archive" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]

  run_archive retrieve old
  [ "$status" -eq 0 ]
  [[ "$output" == *"retrieved      old"* ]]

  [ -f "$ROOT/old/a.txt" ]
  [ ! -e "$ARCHIVE/old.tar.xz" ]
}

# =========================================================
# Collisions
# =========================================================

@test "a directory identical to its archive is reclaimed without a prompt" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  extract_from_archive old

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"reclaiming     old"* ]]

  [ ! -e "$ROOT/old" ]
  [ -f "$ARCHIVE/old.tar.xz" ]
}

@test "a changed directory is left alone by a dry run" {
  collide_with_changed_copy

  run_archive --dry-run
  [ "$status" -eq 1 ]
  [[ "$output" == *"dry run: old left in place"* ]]

  [ -d "$ROOT/old" ]
}

@test "answering r replaces the archive" {
  collide_with_changed_copy

  run_with_answers "r"
  [ "$status" -eq 0 ]
  [[ "$output" == *"replacing      old.tar.xz"* ]]

  [ ! -e "$ROOT/old" ]
  gtar -tJf "$ARCHIVE/old.tar.xz" | grep -qx 'old/new.txt'
}

@test "answering s archives beside the existing archive" {
  collide_with_changed_copy

  run_with_answers "s -"
  [ "$status" -eq 0 ]

  [ ! -e "$ROOT/old" ]
  [ -f "$ARCHIVE/old.tar.xz" ]
  beside=("$ARCHIVE"/old.????-??-??.tar.xz)
  [ -f "${beside[0]}" ]
  gtar -tJf "${beside[0]}" | grep -qx 'old/new.txt'
  original="$(gtar -tJf "$ARCHIVE/old.tar.xz")"
  [[ "$original" != *"old/new.txt"* ]]
}

@test "answering k skips the directory and fails the run" {
  collide_with_changed_copy

  run_with_answers "k"
  [ "$status" -eq 1 ]
  [[ "$output" == *"skipping       old"* ]]

  [ -d "$ROOT/old" ]
}
