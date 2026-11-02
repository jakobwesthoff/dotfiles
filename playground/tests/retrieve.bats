#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load helpers

setup() {
  setup_root
}

# =========================================================
# Archives that are refused
# =========================================================

@test "an archive that cannot be read is refused" {
  printf 'not an archive\n' > "$ARCHIVE/broken.tar.xz"

  run_archive retrieve broken
  [ "$status" -eq 1 ]
  [[ "$output" == *"cannot read broken.tar.xz"* ]]
  [[ "$output" != *"cannot list"* ]]

  [ -f "$ARCHIVE/broken.tar.xz" ]
}

# Half of an archive of incompressible files: the first member is still
# readable, the full listing is not.
@test "a truncated archive is refused before anything is extracted" {
  local i
  for i in $(seq 1 40); do
    mkdir -p "$FOREIGN/big"
    head -c 20000 /dev/urandom > "$FOREIGN/big/file$i"
  done
  touch_tree "$FOREIGN/big" 30
  foreign_archive big big
  size="$(wc -c < "$ARCHIVE/big.tar.xz")"
  head -c $((size / 2)) "$ARCHIVE/big.tar.xz" > "$ARCHIVE/cut.tar.xz"
  rm "$ARCHIVE/big.tar.xz"

  run_archive retrieve cut
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: cannot list cut.tar.xz"* ]]

  [ -f "$ARCHIVE/cut.tar.xz" ]
  [ ! -e "$ROOT/big" ]
  [ ! -e "$ROOT/.retrieve-big" ]
}

@test "an archive of a hidden directory is refused" {
  make_foreign_tree .hidden/f
  foreign_archive hidden .hidden

  run_archive retrieve hidden
  [ "$status" -eq 1 ]
  [[ "$output" == *"holds '.hidden', which cannot be restored into the playground"* ]]

  [ ! -e "$ROOT/.hidden" ]
  [ -f "$ARCHIVE/hidden.tar.xz" ]
}

# $ROOT/archive exists, so a script that only checked for an existing
# directory would refuse this archive too, with a different message.
@test "an archive of a directory named archive is refused" {
  make_foreign_tree archive/f
  foreign_archive other archive

  run_archive retrieve other
  [ "$status" -eq 1 ]
  [[ "$output" == *"holds 'archive', which cannot be restored into the playground"* ]]

  [ -f "$ARCHIVE/other.tar.xz" ]
}

@test "an archive with members outside its directory is refused" {
  make_foreign_tree x/f stray.txt
  foreign_archive mixed x stray.txt

  run_archive retrieve mixed
  [ "$status" -eq 1 ]
  [[ "$output" == *"mixed.tar.xz has 1 members outside x/; refusing to restore it"* ]]

  [ ! -e "$ROOT/x" ]
  [ -f "$ARCHIVE/mixed.tar.xz" ]
}

@test "a directory of the same name in the playground is refused and left alone" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  make_dir old 30
  printf 'newer\n' > "$ROOT/old/a.txt"

  run_archive retrieve old
  [ "$status" -eq 1 ]
  [[ "$output" == *"old already exists in the playground"* ]]
  [[ "$output" == *"retrieving old.tar.xz would overwrite it; move it aside first"* ]]
  [[ "$output" != *"appeared in the playground meanwhile"* ]]

  [ "$(cat "$ROOT/old/a.txt")" = "newer" ]
  [ -f "$ARCHIVE/old.tar.xz" ]
}

@test "a dangling symlink of the same name in the playground is refused" {
  make_unlisted_archive old
  ln -s nowhere "$ROOT/old"

  run_archive retrieve old
  [ "$status" -eq 1 ]
  [[ "$output" == *"old already exists in the playground"* ]]

  [ -L "$ROOT/old" ]
  [ -f "$ARCHIVE/old.tar.xz" ]
}

# =========================================================
# A restore that fails
# =========================================================

@test "a failing extraction keeps the archive and leaves no staging directory" {
  make_unlisted_archive old
  stub_gtar_failing_on_extract

  run_archive retrieve old
  [ "$status" -eq 1 ]
  [[ "$output" == *"extraction failed for old.tar.xz; archive kept"* ]]
  [[ "$output" != *"does not match"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ROOT/old" ]
  [ ! -e "$ROOT/.retrieve-old" ]
}

@test "a restore that does not match the archive is refused and the archive kept" {
  make_unlisted_archive old
  stub_gtar_dropping_a_listing_line

  run_archive retrieve old
  [ "$status" -eq 1 ]
  [[ "$output" == *"entry count mismatch for old"* ]]
  [[ "$output" == *"restored old does not match old.tar.xz; archive kept"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ROOT/old" ]
  [ ! -e "$ROOT/.retrieve-old" ]
}

@test "a name that appears in the playground during the restore is not overwritten" {
  make_unlisted_archive old
  stub_gtar_creating_dir_after_extract "$ROOT/old"

  run_archive retrieve old
  [ "$status" -eq 1 ]
  [[ "$output" == *"old appeared in the playground meanwhile; archive kept"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ -z "$(ls -A "$ROOT/old")" ]
  [ ! -e "$ROOT/.retrieve-old" ]
}

@test "a staging directory left by an interrupted retrieve is discarded" {
  make_unlisted_archive old
  mkdir "$ROOT/.retrieve-old"
  printf 'junk\n' > "$ROOT/.retrieve-old/junk"

  run_archive retrieve old
  [ "$status" -eq 0 ]

  [ -f "$ROOT/old/a.txt" ]
  [ ! -e "$ROOT/.retrieve-old" ]
}

# =========================================================
# A restore that succeeds
# =========================================================

@test "retrieve reports the entries it restored and that the next run archives them" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]

  run_archive retrieve old
  [ "$status" -eq 0 ]
  [[ "$output" == *"retrieving     old from old.tar.xz"* ]]
  [[ "$output" == *"retrieved      old (5 entries), old.tar.xz deleted"* ]]
  [[ "$output" == *"unless something in it changes, the next run archives it again"* ]]
}

# The retrieved .archive-info is stamped at the cutoff when it is written, so
# it is not what makes the directory look recent.
@test "a retrieved directory is archived again by the next run" {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  run_archive retrieve old
  [ "$status" -eq 0 ]

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"archiving      old"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ROOT/old" ]
}

# This archive visits d/sub, leaves it for d/other and returns to it. Tar sets
# a directory's mtime when it leaves it, so without the delayed restore the
# late member would leave d/sub with the extraction time.
@test "directory mtimes survive an archive that returns to a directory" {
  make_foreign_tree d/sub/x d/other/y d/sub/late
  gtar --no-recursion -cf - -C "$FOREIGN" d d/sub d/sub/x d/other d/other/y d/sub/late \
    | xz -c > "$ARCHIVE/d.tar.xz"

  run_archive retrieve d
  [ "$status" -eq 0 ]

  [ -f "$ROOT/d/sub/late" ]
  [ -n "$(find "$ROOT/d/sub" -maxdepth 0 -mtime +20)" ]
}

# =========================================================
# Other archives of the same directory
# =========================================================

@test "retrieve lists the archives of the directory that remain" {
  make_dir x 30
  run_archive
  [ "$status" -eq 0 ]
  cp "$ARCHIVE/x.tar.xz" "$ARCHIVE/x.2026-01-01.tar.xz"

  run_archive retrieve x.tar.xz
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> more archives of x remain <<<"* ]]
  [[ "$output" == *"  x.2026-01-01.tar.xz"* ]]
  [[ "$output" != *"  x.tar.xz"* ]]
}

# "x.1.tar.xz" matches the glob for x but holds the directory x.1.
@test "the archive of a dotted directory name is not an archive of its prefix" {
  make_unlisted_archive x
  make_unlisted_archive x.1

  run_archive retrieve x.tar.xz
  [ "$status" -eq 0 ]
  [[ "$output" != *"more archives of x remain"* ]]

  [ -f "$ARCHIVE/x.1.tar.xz" ]
}
