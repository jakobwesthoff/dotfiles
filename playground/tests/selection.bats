#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load helpers

setup() {
  setup_root
}

# =========================================================
# list
# =========================================================

@test "list without a pattern prints every archive as date, size and name" {
  make_unlisted_archive alpha
  make_unlisted_archive beta

  run_archive list
  [ "$status" -eq 0 ]
  grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2} +[0-9.]+[BKMG]? +alpha\.tar\.xz$' <<< "$output"
  grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2} +[0-9.]+[BKMG]? +beta\.tar\.xz$' <<< "$output"
}

@test "list ignores the case of the pattern" {
  make_unlisted_archive alpha
  make_unlisted_archive beta

  run_archive list ALPHA
  [ "$status" -eq 0 ]
  [[ "$output" == *"alpha.tar.xz"* ]]
  [[ "$output" != *"beta.tar.xz"* ]]
}

# A dot would match any character if the pattern were a regular expression.
@test "list takes the pattern literally" {
  make_unlisted_archive alpha

  run_archive_split list 'a.p'
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"no archive name contains 'a.p'"* ]]
}

@test "list dies when no archive name contains the pattern" {
  make_unlisted_archive alpha

  run_archive_split list zzz
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"no archive name contains 'zzz'"* ]]
  [ -z "$output" ]
}

# =========================================================
# Picking an archive without a picker
# =========================================================

# "proj" is part of both names, so only the exact-name test can pick it.
@test "retrieve takes an exact archive name without its suffix" {
  make_unlisted_archive proj
  make_unlisted_archive proj.1

  run_without_terminal retrieve proj
  [ "$status" -eq 0 ]
  [[ "$output" == *"retrieved      proj ("* ]]

  [ -d "$ROOT/proj" ]
  [ ! -e "$ARCHIVE/proj.tar.xz" ]
  [ -f "$ARCHIVE/proj.1.tar.xz" ]
}

# "xproj.tar.xz" also contains the pattern, so the single-match shortcut
# cannot stand in for the exact-name test.
@test "retrieve takes an exact archive name with its suffix" {
  make_unlisted_archive proj
  make_unlisted_archive xproj

  run_without_terminal retrieve proj.tar.xz
  [ "$status" -eq 0 ]
  [[ "$output" == *"retrieved      proj ("* ]]

  [ -d "$ROOT/proj" ]
  [ -f "$ARCHIVE/xproj.tar.xz" ]
}

@test "retrieve takes the only archive whose name contains the pattern" {
  make_unlisted_archive alpha
  make_unlisted_archive beta

  run_without_terminal retrieve alp
  [ "$status" -eq 0 ]

  [ -d "$ROOT/alpha" ]
  [ -f "$ARCHIVE/beta.tar.xz" ]
}

@test "retrieve dies when no archive name contains the pattern" {
  make_unlisted_archive alpha

  run_without_terminal retrieve zzz
  [ "$status" -eq 1 ]
  [[ "$output" == *"no archive name contains 'zzz'"* ]]
  [[ "$output" != *"archives match"* ]]

  [ -f "$ARCHIVE/alpha.tar.xz" ]
}

@test "retrieve dies when there are no archives to pick from" {
  run_without_terminal retrieve
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: no archives to retrieve"* ]]
  [[ "$output" != *"archives match"* ]]
  [[ "$output" != *"unbound variable"* ]]
}

# fzf is stubbed to see whether it is started.
@test "retrieve on a terminal does not open fzf when there are no archives" {
  stub_fzf

  run_with_answers "" retrieve
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: no archives to retrieve"* ]]

  [ ! -e "$FZF_ARGS_FILE" ]
}

@test "retrieve with a pattern names the pattern when there are no archives" {
  run_without_terminal retrieve zzz
  [ "$status" -eq 1 ]
  [[ "$output" == *"no archive name contains 'zzz'"* ]]
  [[ "$output" != *"no archives to retrieve"* ]]
}

# fzf is stubbed so that a script which wrongly opens it does not wait on a
# real picker.
@test "retrieve without a terminal dies on several matches and names them" {
  make_unlisted_archive proj-a
  make_unlisted_archive proj-b
  stub_fzf

  run_without_terminal retrieve proj
  [ "$status" -eq 1 ]
  [[ "$output" == *"proj-a.tar.xz"* ]]
  [[ "$output" == *"proj-b.tar.xz"* ]]
  [[ "$output" == *"2 archives match; give a pattern that matches only one"* ]]

  [ -f "$ARCHIVE/proj-a.tar.xz" ]
  [ -f "$ARCHIVE/proj-b.tar.xz" ]
}

@test "retrieve on a terminal without fzf dies on several matches" {
  make_unlisted_archive proj-a
  make_unlisted_archive proj-b
  path_without fzf

  run_with_answers ""  retrieve proj
  [ "$status" -eq 1 ]
  [[ "$output" == *"2 archives match; give a pattern that matches only one"* ]]

  [ -f "$ARCHIVE/proj-a.tar.xz" ]
  [ -f "$ARCHIVE/proj-b.tar.xz" ]
}

@test "retrieve without a pattern never picks by itself" {
  make_unlisted_archive alpha
  stub_fzf

  run_without_terminal retrieve
  [ "$status" -eq 1 ]
  [[ "$output" == *"archives match; give a pattern that matches only one"* ]]
  [[ "$output" == *"alpha.tar.xz"* ]]

  [ -f "$ARCHIVE/alpha.tar.xz" ]
}

# =========================================================
# Picking an archive with fzf
# =========================================================

@test "retrieve restores the archive fzf returns and offers every archive" {
  make_unlisted_archive proj-a
  make_unlisted_archive proj-b
  make_unlisted_archive other
  stub_fzf proj-b.tar.xz

  run_with_answers "" retrieve proj
  [ "$status" -eq 0 ]

  [ -d "$ROOT/proj-b" ]
  [ ! -e "$ROOT/proj-a" ]
  [ ! -e "$ARCHIVE/proj-b.tar.xz" ]
  [ -f "$ARCHIVE/proj-a.tar.xz" ]
  [ "$(cat "$FZF_INPUT_FILE")" = "$(printf 'other.tar.xz\nproj-a.tar.xz\nproj-b.tar.xz')" ]
}

@test "the pattern is fzf's starting query" {
  make_unlisted_archive proj-a
  make_unlisted_archive proj-b
  stub_fzf proj-a.tar.xz

  run_with_answers "" retrieve proj
  [ "$status" -eq 0 ]

  [ "$(fzf_option_value --query)" = "proj" ]
}

@test "retrieve without a pattern opens fzf even for a single archive" {
  make_unlisted_archive alpha
  stub_fzf alpha.tar.xz

  run_with_answers "" retrieve
  [ "$status" -eq 0 ]

  [ -s "$FZF_INPUT_FILE" ]
  [ -d "$ROOT/alpha" ]
}

@test "leaving fzf without a pick retrieves nothing and succeeds" {
  make_unlisted_archive proj-a
  make_unlisted_archive proj-b
  stub_fzf

  run_with_answers "" retrieve proj
  [ "$status" -eq 0 ]
  [[ "$output" == *"nothing picked"* ]]

  [ -f "$ARCHIVE/proj-a.tar.xz" ]
  [ -f "$ARCHIVE/proj-b.tar.xz" ]
  [ ! -e "$ROOT/proj-a" ]
}
