#!/usr/bin/env bats

load helpers

setup() {
  setup_root
}

# =========================================================
# Choices
# =========================================================

@test "R replaces the archive" {
  collide_with_changed_copy

  run_with_answers "R"
  [ "$status" -eq 0 ]
  [[ "$output" == *"replacing      old.tar.xz"* ]]
  [[ "$output" == *"reclaimed: 0   replaced: 1   beside: 0   unresolved: 0"* ]]

  gtar -tJf "$ARCHIVE/old.tar.xz" | grep -qx 'old/new.txt'
}

@test "S archives beside the existing archive" {
  collide_with_changed_copy

  run_with_answers "S -"
  [ "$status" -eq 0 ]
  [[ "$output" == *"reclaimed: 0   replaced: 0   beside: 1   unresolved: 0"* ]]

  beside=("$ARCHIVE"/old.????-??-??.tar.xz)
  [ -f "${beside[0]}" ]
}

@test "K skips the directory" {
  collide_with_changed_copy

  run_with_answers "K"
  [ "$status" -eq 1 ]
  [[ "$output" == *"skipping       old"* ]]
}

@test "an answer that is none of r, s or k is rejected and asked again" {
  collide_with_changed_copy

  run_with_answers "x r"
  [ "$status" -eq 0 ]
  [[ "$output" == *"answer r, s or k"* ]]
  [[ "$output" == *"replacing      old.tar.xz"* ]]
}

@test "k leaves the directory and the archive as they were" {
  collide_with_changed_copy
  cp "$ARCHIVE/old.tar.xz" "$BATS_TEST_TMPDIR/before.tar.xz"

  run_with_answers "k"
  [ "$status" -eq 1 ]
  [[ "$output" == *"unresolved: 1"* ]]

  cmp "$ARCHIVE/old.tar.xz" "$BATS_TEST_TMPDIR/before.tar.xz"
  [ -f "$ROOT/old/new.txt" ]
}

@test "the end of input at the choice skips the directory" {
  collide_with_changed_copy

  run_with_answers "^D"
  [ "$status" -eq 1 ]
  [[ "$output" == *"skipping       old"* ]]

  [ -f "$ROOT/old/new.txt" ]
}

@test "a dry run never prompts, even on a terminal" {
  collide_with_changed_copy

  run_with_answers "" --dry-run
  [ "$status" -eq 1 ]
  [[ "$output" == *"dry run: old left in place"* ]]
  [[ "$output" != *"choice [r/s/k]"* ]]
}

# =========================================================
# What replacing costs
# =========================================================

# The directory only grew, and new.txt carries its own stamp so that the
# archived files are not re-stamped.
@test "the prompt says replacing loses nothing for a directory that only grew" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  extract_from_archive old
  printf 'gamma\n' > "$ROOT/old/new.txt"
  touch -t "$(stamp_days_ago 30)" "$ROOT/old/new.txt"

  run_with_answers "k"
  [ "$status" -eq 1 ]
  [[ "$output" == *"replacing loses nothing: the directory contains everything the archive does"* ]]
  [[ "$output" != *"discards"* ]]
}

# Re-stamping the whole tree changes the record's mtime too, which is one more
# changed path besides the edited a.txt. a.txt gets its own stamp: with the
# archived one, only its content would differ.
@test "the prompt counts changed and removed paths when replacing discards content" {
  collide_with_changed_copy
  rm "$ROOT/old/sub/b.txt"
  printf 'alphX\n' > "$ROOT/old/a.txt"
  touch -t "$(stamp_days_ago 20)" "$ROOT/old/a.txt"

  run_with_answers "k"
  [ "$status" -eq 1 ]
  [[ "$output" == *"replacing discards content kept nowhere else: 2 changed, 1 removed"* ]]
  [[ "$output" != *"loses nothing"* ]]
}

# =========================================================
# Naming the archive kept beside
# =========================================================

@test "the default suffix is the date, offered in the menu and at the suffix prompt" {
  collide_with_changed_copy

  run_with_answers "s -"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[r] replace old.tar.xz"* ]]
  [[ "$output" == *"[k] skip, leave the directory and the archive as they are"* ]]
  [[ "$output" =~ archive\ beside\ it\ as\ old\.([0-9]{4}-[0-9]{2}-[0-9]{2})\.tar\.xz ]]
  day="${BASH_REMATCH[1]}"
  [[ "$output" == *"suffix [$day]: "* ]]
  [[ "$output" == *"archiving      old.$day"* ]]

  [ -f "$ARCHIVE/old.$day.tar.xz" ]
}

@test "a suffix typed at the prompt names the archive" {
  collide_with_changed_copy

  run_with_answers "s mine"
  [ "$status" -eq 0 ]
  [[ "$output" == *"archiving      old.mine"* ]]

  gtar -tJf "$ARCHIVE/old.mine.tar.xz" | grep -qx 'old/new.txt'
}

# A slash would reach into another directory and a dot would make the name
# ambiguous with a directory name. Hyphen, underscore and digits are allowed.
@test "a suffix with a slash or a dot is rejected and asked again" {
  collide_with_changed_copy

  run_with_answers "s a/b c.d ok_1-x"
  [ "$status" -eq 0 ]
  [ "$(grep -c 'suffix may only contain letters, digits, underscore and hyphen' <<< "$output")" -eq 2 ]

  [ -f "$ARCHIVE/old.ok_1-x.tar.xz" ]
}

@test "a suffix that names an existing archive is rejected and asked again" {
  collide_with_changed_copy
  : > "$ARCHIVE/old.taken.tar.xz"

  run_with_answers "s taken mine"
  [ "$status" -eq 0 ]
  [[ "$output" == *"old.taken.tar.xz already exists"* ]]

  [ -f "$ARCHIVE/old.mine.tar.xz" ]
  [ ! -s "$ARCHIVE/old.taken.tar.xz" ]
}

@test "the end of input at the suffix prompt takes the default suffix" {
  collide_with_changed_copy

  run_with_answers "s ^D"
  [ "$status" -eq 0 ]
  [[ "$output" =~ archiving\ \ \ \ \ \ old\.[0-9]{4}-[0-9]{2}-[0-9]{2} ]]
}

# The counter starts at 2 and goes on while the name is taken.
@test "the default suffix gets a counter when its name is taken" {
  make_two_archives_of_old
  # shellcheck disable=SC2153 # BESIDE is set by make_two_archives_of_old
  day="$(basename "$BESIDE" .tar.xz)"
  extract_from_archive old
  printf 'two\n' > "$ROOT/old/two.txt"
  touch -t "$(stamp_days_ago 30)" "$ROOT/old/two.txt"

  run_with_answers "s -"
  [ "$status" -eq 0 ]
  [[ "$output" == *"archive beside it as $day-2.tar.xz"* ]]
  [ -f "$ARCHIVE/$day-2.tar.xz" ]

  extract_from_archive old
  printf 'three\n' > "$ROOT/old/three.txt"
  touch -t "$(stamp_days_ago 30)" "$ROOT/old/three.txt"

  run_with_answers "s -"
  [ "$status" -eq 0 ]
  [[ "$output" == *"archive beside it as $day-3.tar.xz"* ]]
  [ -f "$ARCHIVE/$day-3.tar.xz" ]
}
