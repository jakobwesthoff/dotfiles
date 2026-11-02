#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load helpers

setup() {
  setup_root
  LISTING="$ARCHIVE/index/old.tar.xz.lst"
}

teardown() {
  restore_permissions
}

# =========================================================
# Writing a listing
# =========================================================

@test "the first archive of a directory gets a listing" {
  make_dir old 30

  run_archive
  [ "$status" -eq 0 ]

  [ -f "$LISTING" ]
  grep -q ' old/sub/b.txt$' "$LISTING"
  grep -q '^-rw-r--r-- ' "$LISTING"
}

@test "the listing matches tar -tv byte for byte for awkward names" {
  make_dir old 30
  printf 'x\n' > "$ROOT/old/Grüße 1.txt"
  ln -s a.txt "$ROOT/old/link to a"
  ln -s $'multi\nline' "$ROOT/old/newline target"
  touch_tree "$ROOT/old" 30

  run_archive
  [ "$status" -eq 0 ]

  listing_oracle "$ARCHIVE/old.tar.xz" > "$BATS_TEST_TMPDIR/expected"
  cmp "$BATS_TEST_TMPDIR/expected" "$LISTING"
}

@test "an archive placed beside another gets its own listing" {
  collide_with_changed_copy

  run_with_answers "s -"
  [ "$status" -eq 0 ]

  beside=("$ARCHIVE"/old.????-??-??.tar.xz)
  beside_listing="$ARCHIVE/index/$(basename "${beside[0]}").lst"
  grep -q ' old/new.txt$' "$beside_listing"
  run ! grep -q ' old/new.txt$' "$LISTING"
}

@test "a replaced archive takes its listing along" {
  collide_with_changed_copy

  run_with_answers "r"
  [ "$status" -eq 0 ]

  grep -q ' old/new.txt$' "$LISTING"
}

@test "the index directory is not moved back into the playground" {
  mkdir -p "$ARCHIVE/index"
  printf 'listing\n' > "$ARCHIVE/index/kept.tar.xz.lst"

  run_archive
  [ "$status" -eq 0 ]

  [ -f "$ARCHIVE/index/kept.tar.xz.lst" ]
  [ ! -e "$ROOT/index" ]
}

@test "a dry run writes no listing and creates no index directory" {
  make_dir old 30

  run_archive --dry-run
  [ "$status" -eq 0 ]

  [ ! -e "$ARCHIVE/index" ]
}

# =========================================================
# A listing that cannot be written
# =========================================================

@test "a listing that cannot be put in place is a warning" {
  make_dir old 30
  stub_mv_failing_on_listing_parts

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"could not write the listing of old.tar.xz"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ROOT/old" ]
  [ ! -e "$LISTING" ]
  [ ! -e "$LISTING.part" ]
}

@test "a regular file in place of the index directory is a warning" {
  make_dir old 30
  : > "$ARCHIVE/index"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"could not write the listing of old.tar.xz"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ROOT/old" ]
}

@test "a failing listing does not stop the run" {
  make_dir one 30
  make_dir two 30
  stub_mv_failing_on_listing_parts

  run_archive
  [ "$status" -eq 0 ]

  [ -f "$ARCHIVE/one.tar.xz" ]
  [ -f "$ARCHIVE/two.tar.xz" ]
  [ ! -e "$ROOT/one" ]
  [ ! -e "$ROOT/two" ]
  [ "$(grep -c 'could not write the listing' <<< "$output")" -eq 2 ]
}

@test "an orphan listing of the same name does not outlive a failed write" {
  make_dir old 30
  mkdir -p "$ARCHIVE/index"
  printf 'orphan\n' > "$LISTING"
  stub_mv_failing_on_listing_parts

  run_archive
  [ "$status" -eq 0 ]

  [ ! -e "$LISTING" ]
}

@test "a replaced archive does not keep the old listing when the new one fails" {
  collide_with_changed_copy
  stub_mv_failing_on_listing_parts

  run_with_answers "r"
  [ "$status" -eq 0 ]
  [[ "$output" == *"could not write the listing of old.tar.xz"* ]]

  [ ! -e "$LISTING" ]
}

@test "an old listing that cannot be deleted is reported as stale" {
  collide_with_changed_copy
  chmod 555 "$ARCHIVE/index"

  run_with_answers "r"
  [ "$status" -eq 0 ]
  [[ "$output" == *"stale"* ]]

  gtar -tJf "$ARCHIVE/old.tar.xz" | grep -qx 'old/new.txt'
}

# =========================================================
# Retrieving
# =========================================================

@test "retrieve deletes the listing of the retrieved archive" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  mkdir -p "$ARCHIVE/index"
  printf 'listing\n' > "$LISTING"

  run_archive retrieve old
  [ "$status" -eq 0 ]

  [ ! -e "$LISTING" ]
}

@test "retrieve keeps the listings of other archives" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  mkdir -p "$ARCHIVE/index"
  printf 'listing\n' > "$ARCHIVE/index/other.tar.xz.lst"

  run_archive retrieve old
  [ "$status" -eq 0 ]

  [ -f "$ARCHIVE/index/other.tar.xz.lst" ]
}

@test "retrieve completes when the listing cannot be deleted" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  mkdir -p "$ARCHIVE/index"
  printf 'listing\n' > "$LISTING"
  chmod 555 "$ARCHIVE/index"

  run_archive retrieve old
  [ "$status" -eq 0 ]
  [[ "$output" == *"could not delete listing old.tar.xz.lst"* ]]

  [ -f "$ROOT/old/a.txt" ]
  [ ! -e "$ARCHIVE/old.tar.xz" ]
}
