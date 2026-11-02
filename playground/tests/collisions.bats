#!/usr/bin/env bats

load helpers

setup() {
  setup_root
}

# =========================================================
# Identical content
# =========================================================

@test "a dry run reports the reclaim of an identical directory and keeps it" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  extract_from_archive old

  run_archive --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would reclaim  old (identical to old.tar.xz)"* ]]
  [[ "$output" == *"reclaimed: 1"* ]]

  [ -d "$ROOT/old" ]
}

# The plain archive differs from the directory, so only the second archive
# can show that nothing would be lost.
@test "a directory identical to any of its archives is reclaimed" {
  make_two_archives_of_old
  gtar -xJf "$BESIDE" -C "$ROOT"

  run_without_terminal
  [ "$status" -eq 0 ]
  [[ "$output" == *"reclaiming     old (identical to $(basename "$BESIDE"))"* ]]

  [ ! -e "$ROOT/old" ]
  [ -f "$ARCHIVE/old.tar.xz" ]
  [ -f "$BESIDE" ]
}

# =========================================================
# Without a terminal
# =========================================================

@test "a changed directory is left in place when there is nobody to ask" {
  collide_with_changed_copy
  cp "$ARCHIVE/old.tar.xz" "$BATS_TEST_TMPDIR/before.tar.xz"

  run_without_terminal
  [ "$status" -eq 1 ]
  [[ "$output" == *"no terminal to ask on: old left in place"* ]]
  [[ "$output" == *"unresolved: 1"* ]]
  [[ "$output" != *"choice [r/s/k]"* ]]

  [ -f "$ROOT/old/new.txt" ]
  cmp "$ARCHIVE/old.tar.xz" "$BATS_TEST_TMPDIR/before.tar.xz"
}

# =========================================================
# The report of a collision
# =========================================================

# Every kind of difference once or more: two identical files, one whose
# content differs, one whose mtime differs, five only on disk and two only in
# the archive. The edited file gets its own stamp, otherwise it would have the
# archived mtime and the content change would not be reported twice.
@test "the report breaks the difference down by kind and names up to three entries" {
  make_archive_of old same1 same2 chg meta gone1 gone2
  make_files "$ROOT/old" same1 same2 chg meta new1 new2 new3 new4 new5
  printf 'chX\n' > "$ROOT/old/chg"
  touch -t "$(stamp_days_ago 20)" "$ROOT/old/chg"
  touch -t "$(stamp_days_ago 25)" "$ROOT/old/meta"

  run_archive --dry-run
  [ "$status" -eq 1 ]
  [[ "$output" == *">>> old already has an archive <<<"* ]]
  grep -Eq '^  archive    old\.tar\.xz$' <<< "$output"
  grep -Eq '^             [0-9]{4}-[0-9]{2}-[0-9]{2}   [0-9.]+[BKMG]?   6 entries$' <<< "$output"
  grep -Eq '^  on disk    [0-9.]+[BKMG]?   9 entries$' <<< "$output"
  grep -Eq '^  overlap    4/11 paths \(36%\)$' <<< "$output"
  grep -Eq '^    identical +2$' <<< "$output"
  grep -Eq '^    content differs +1   chg$' <<< "$output"
  grep -Eq '^    metadata differs +1   meta$' <<< "$output"
  grep -Eq '^    only on disk +5   new1, new2, new3$' <<< "$output"
  grep -Eq '^    only in archive +2   gone1, gone2$' <<< "$output"
  [[ "$output" != *"closest of"* ]]
}

# Two archives of the directory are compared, and the report describes the one
# that overlaps most. The beside archive is last in the comparison order.
@test "the report names the closest of several archives when it was compared last" {
  make_two_archives_of_old
  gtar -xJf "$BESIDE" -C "$ROOT"
  printf 'extra\n' > "$ROOT/old/extra.txt"
  touch -t "$(stamp_days_ago 30)" "$ROOT/old/extra.txt"

  run_archive --dry-run
  [ "$status" -eq 1 ]
  grep -Eq "^  archive    $(basename "$BESIDE")\$" <<< "$output"
  [[ "$output" == *"closest of 2 archives on this name"* ]]
  [[ "$output" == *"(83%)"* ]]
}

# The plain archive is compared first and wins, so the figures of the archive
# compared last have to be replaced by its own.
@test "the report names the closest of several archives when it was compared first" {
  make_two_archives_of_old
  extract_from_archive old
  printf 'extra\n' > "$ROOT/old/extra.txt"
  touch -t "$(stamp_days_ago 30)" "$ROOT/old/extra.txt"

  run_archive --dry-run
  [ "$status" -eq 1 ]
  grep -Eq '^  archive    old\.tar\.xz$' <<< "$output"
  [[ "$output" == *"closest of 2 archives on this name"* ]]
  [[ "$output" == *"(80%)"* ]]
}

# =========================================================
# How the overlap reads
# =========================================================

# The archive holds ten files, or eighteen for the 59% case. The directory
# shares some of them and adds others, so that the shared paths stand to the
# union of both trees as the test name says.

@test "60 percent overlap reads as a modified copy" {
  make_archive_of old f{1..10}
  make_files "$ROOT/old" f{1..6}

  run_archive --dry-run
  [[ "$output" == *"overlap    6/10 paths (60%)"* ]]
  [[ "$output" == *"reads as: modified copy of this archive"* ]]
}

@test "59 percent overlap reads as unclear" {
  make_archive_of old a{1..13} b{1..5}
  make_files "$ROOT/old" a{1..13} c{1..4}

  run_archive --dry-run
  [[ "$output" == *"overlap    13/22 paths (59%)"* ]]
  [[ "$output" == *"reads as: unclear, inspect before deciding"* ]]
}

@test "20 percent overlap reads as unclear" {
  make_archive_of old f{1..10}
  make_files "$ROOT/old" f{1..4} g{1..10}

  run_archive --dry-run
  [[ "$output" == *"overlap    4/20 paths (20%)"* ]]
  [[ "$output" == *"reads as: unclear, inspect before deciding"* ]]
}

@test "19 percent overlap reads as an unrelated directory" {
  make_archive_of old f{1..10}
  make_files "$ROOT/old" f{1..4} g{1..11}

  run_archive --dry-run
  [[ "$output" == *"overlap    4/21 paths (19%)"* ]]
  [[ "$output" == *"reads as: unrelated directory sharing the name"* ]]
}

# =========================================================
# Which archive belongs to which directory
# =========================================================

# "x.1.tar.xz" matches the glob for x but holds the directory x.1.
@test "the archive of a dotted directory name is not counted among the archives of its prefix" {
  make_unlisted_archive x
  make_unlisted_archive x.1
  make_dir x 30
  printf 'more\n' > "$ROOT/x/more"
  touch -t "$(stamp_days_ago 30)" "$ROOT/x/more"

  run_archive --dry-run
  [ "$status" -eq 1 ]
  grep -Eq '^  archive    x\.tar\.xz$' <<< "$output"
  [[ "$output" != *"closest of"* ]]
}

@test "an archive named for a dotted directory but holding x counts as an archive of x" {
  make_unlisted_archive x
  mv "$ARCHIVE/x.tar.xz" "$ARCHIVE/x.1.tar.xz"
  gtar -xJf "$ARCHIVE/x.1.tar.xz" -C "$ROOT"

  run_archive --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would reclaim  x (identical to x.1.tar.xz)"* ]]
}
