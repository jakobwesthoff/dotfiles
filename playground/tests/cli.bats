#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load helpers

setup() {
  setup_root
}

# =========================================================
# The helper for runs without a terminal
# =========================================================

# Both sides run on a pseudo-terminal. Outside one, opening /dev/tty fails
# with or without the session change, so a probe made anywhere else would
# pass whatever the helper does.
@test "a command started through NO_TERMINAL cannot open /dev/tty, one without it can" {
  run bash -c 'ANSWERS="" expect "$1" bash -c ": < /dev/tty"' _ "$ANSWER_EXP"
  [ "$status" -eq 0 ]

  run bash -c 'ANSWERS="" expect "$1" "${@:2}" bash -c ": < /dev/tty"' \
    _ "$ANSWER_EXP" "${NO_TERMINAL[@]}"
  [ "$status" -ne 0 ]
}

# =========================================================
# Usage
# =========================================================

@test "-h prints the usage on stdout and nothing on stderr" {
  run_archive_split -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage: archive.sh [--dry-run]"* ]]
  [ -z "$stderr" ]
}

@test "an unknown command prints the usage on stderr and exits 2" {
  run_archive_split frobnicate
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"usage: archive.sh [--dry-run]"* ]]
  [ -z "$output" ]
}

# =========================================================
# Argument counts
# =========================================================

@test "--dry-run takes no further argument" {
  make_dir old 30

  run_archive --dry-run extra
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: archive.sh"* ]]

  [ -d "$ROOT/old" ]
}

# An empty first word selects the archiving run, as no word at all does.
@test "an archiving run takes no argument after an empty first word" {
  make_dir old 30

  run_archive "" extra
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: archive.sh"* ]]

  [ -d "$ROOT/old" ]
}

@test "list takes at most one pattern" {
  run_archive list one two
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: archive.sh"* ]]
}

@test "retrieve takes at most one pattern" {
  make_unlisted_archive old

  run_archive retrieve one two
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: archive.sh"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
}

# =========================================================
# What the script needs before it starts
# =========================================================

@test "a missing archive directory stops the script before any work" {
  make_dir old 30
  rmdir "$ARCHIVE"

  run_archive_split
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"archive directory not found: "* ]]

  [ -d "$ROOT/old" ]
}

@test "a missing gtar stops the script" {
  path_without gtar

  run_archive_split list
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"gtar (GNU tar) is required"* ]]
}

@test "a missing gsed stops the script" {
  path_without gsed

  run_archive_split list
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"gsed (GNU sed) is required"* ]]
}

@test "a missing xz stops the script" {
  path_without xz

  run_archive_split list
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"xz is required"* ]]
}

# =========================================================
# The bash version the script needs
# =========================================================

@test "--help under an older bash stops with a message and prints no usage" {
  skip_unless_system_bash_is_old

  run_archive_under_system_bash --help
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"ERROR: archive.sh needs bash 4.4 or newer, but runs under bash $(system_bash_version) ($SYSTEM_BASH)"* ]]
}

@test "an archiving run under an older bash changes nothing" {
  skip_unless_system_bash_is_old
  make_dir old 30

  run_archive_under_system_bash
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"needs bash 4.4 or newer"* ]]

  [ -d "$ROOT/old" ]
  [ -z "$(ls -A "$ARCHIVE")" ]
}

@test "the version test refuses bash before 4.4 and accepts 4.4 and newer" {
  assert_version_test_draws_the_line_at_4_4 "$ROOT/archive.sh"
}
