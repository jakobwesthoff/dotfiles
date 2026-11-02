#!/usr/bin/env bats

load helpers

setup() {
  setup_root
}

# =========================================================
# Directories the run leaves alone
# =========================================================

# The marker is aged with the rest of the tree, so only the marker check keeps
# the directory out of the archive.
@test "a .no-archive marker keeps an aged-out directory" {
  make_dir keep 30
  touch "$ROOT/keep/.no-archive"
  touch_tree "$ROOT/keep" 30

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> keep skipped: .no-archive present <<<"* ]]
  [[ "$output" == *"no-archive: 1"* ]]

  [ -d "$ROOT/keep" ]
  [ ! -e "$ARCHIVE/keep.tar.xz" ]
}

# The target sits outside the playground and is aged with everything else, so
# only the link check keeps it out of the archive.
@test "a symlinked directory is left in place and its target is untouched" {
  make_dir_in "$OUTSIDE" real 30
  ln -s "$OUTSIDE/real" "$ROOT/linked"
  local before
  before="$(tree_state "$OUTSIDE/real")"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> linked skipped: symlink <<<"* ]]
  [[ "$output" == *"symlinks: 1"* ]]

  [ "$(readlink "$ROOT/linked")" = "$OUTSIDE/real" ]
  [ "$(tree_state "$OUTSIDE/real")" = "$before" ]
  [ -z "$(ls -A "$ARCHIVE")" ]
}

@test "a dry run names a symlinked directory" {
  make_dir_in "$OUTSIDE" real 30
  ln -s "$OUTSIDE/real" "$ROOT/linked"

  run_archive --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> linked skipped: symlink <<<"* ]]
  [[ "$output" != *"would archive  linked"* ]]
}

# Removing a link to an empty tree with rm -rf and a trailing slash removes the
# target on macOS, so the link check has to come before the empty-tree check.
@test "a symlink to a directory holding no files leaves the target in place" {
  mkdir -p "$OUTSIDE/hollow/skeleton"
  ln -s "$OUTSIDE/hollow" "$ROOT/linked"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> linked skipped: symlink <<<"* ]]

  [ -L "$ROOT/linked" ]
  [ -d "$OUTSIDE/hollow/skeleton" ]
}

# The middle link lies outside the playground, so the run sees the chain as one
# entry.
@test "a symlink to a symlink to a directory is skipped" {
  make_dir_in "$OUTSIDE" real 30
  ln -s "$OUTSIDE/real" "$OUTSIDE/hop"
  ln -s "$OUTSIDE/hop" "$ROOT/chained"
  local before
  before="$(tree_state "$OUTSIDE/real")"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> chained skipped: symlink <<<"* ]]
  [[ "$output" == *"symlinks: 1"* ]]

  [ "$(readlink "$ROOT/chained")" = "$OUTSIDE/hop" ]
  [ "$(readlink "$OUTSIDE/hop")" = "$OUTSIDE/real" ]
  [ "$(tree_state "$OUTSIDE/real")" = "$before" ]
}

@test "a symlink to a directory of the playground is skipped while the directory is archived" {
  make_dir old 30
  ln -s "$ROOT/old" "$ROOT/alias"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> alias skipped: symlink <<<"* ]]
  [[ "$output" == *"archiving      old"* ]]

  [ -f "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ARCHIVE/alias.tar.xz" ]
  [ -L "$ROOT/alias" ]
}

@test "a symlink counts as a symlink whatever its target says about .no-archive" {
  make_dir_in "$OUTSIDE" real 30
  touch "$OUTSIDE/real/.no-archive"
  ln -s "$OUTSIDE/real" "$ROOT/linked"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> linked skipped: symlink <<<"* ]]
  [[ "$output" == *"no-archive: 0   symlinks: 1"* ]]
}

# Neither kind matches the */ glob, so neither was ever a candidate. The
# stowed scripts in the real playground are links to files.
@test "a symlink to a file and a dangling symlink are neither named nor touched" {
  mkdir -p "$OUTSIDE"
  printf 'x\n' > "$OUTSIDE/file"
  ln -s "$OUTSIDE/file" "$ROOT/filelink"
  ln -s "$OUTSIDE/nowhere" "$ROOT/dangling"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" != *"filelink"* ]]
  [[ "$output" != *"dangling"* ]]
  [[ "$output" == *"symlinks: 0"* ]]

  [ "$(readlink "$ROOT/filelink")" = "$OUTSIDE/file" ]
  [ "$(readlink "$ROOT/dangling")" = "$OUTSIDE/nowhere" ]
  [ "$(cat "$OUTSIDE/file")" = "x" ]
}

@test "a dry run reports an empty directory and keeps it" {
  mkdir -p "$ROOT/hollow/skeleton"

  run_archive --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would remove   hollow (empty)"* ]]
  [[ "$output" == *"(dry run, nothing will be written or deleted)"* ]]

  [ -d "$ROOT/hollow/skeleton" ]
}

@test "a dry run reports a directory to restore and leaves it in archive/" {
  mkdir -p "$ARCHIVE/stray"
  printf 'x\n' > "$ARCHIVE/stray/f"

  run_archive --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would restore  stray (uncompressed, from archive/)"* ]]

  [ -f "$ARCHIVE/stray/f" ]
  [ ! -e "$ROOT/stray" ]
}

@test "a symlinked directory in archive/ is not moved to the playground" {
  make_dir_in "$OUTSIDE" real 30
  ln -s "$OUTSIDE/real" "$ARCHIVE/lnk"
  local before
  before="$(tree_state "$OUTSIDE/real")"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> archive/lnk skipped: symlink <<<"* ]]
  [[ "$output" == *"symlinks: 1"* ]]

  [ "$(readlink "$ARCHIVE/lnk")" = "$OUTSIDE/real" ]
  [ ! -e "$ROOT/lnk" ]
  [ "$(tree_state "$OUTSIDE/real")" = "$before" ]
}

# A plain file keeps the name taken without being a directory of the
# playground, so it survives the archiving loop and reaches the restore.
@test "a directory in archive/ is not moved over an existing name" {
  mkdir -p "$ARCHIVE/stray"
  printf 'x\n' > "$ARCHIVE/stray/f"
  printf 'occupied\n' > "$ROOT/stray"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"cannot restore stray: a directory of that name already exists"* ]]

  [ -f "$ARCHIVE/stray/f" ]
  [ "$(cat "$ROOT/stray")" = "occupied" ]
}

# =========================================================
# The report of a run
# =========================================================

@test "the cutoff line names the day AGE_DAYS back" {
  local before after
  before="$(stamp_days_ago 14)"
  run_archive
  after="$(stamp_days_ago 14)"
  [ "$status" -eq 0 ]

  [[ "$output" == *"cutoff: directories untouched since ${before:0:8} are archived"* \
    || "$output" == *"cutoff: directories untouched since ${after:0:8} are archived"* ]]
}

@test "the summary counts every kind of directory" {
  make_dir old 30
  make_dir young 1
  make_dir keep 30
  touch "$ROOT/keep/.no-archive"
  touch_tree "$ROOT/keep" 30
  mkdir -p "$ROOT/hollow/skeleton"
  mkdir -p "$ARCHIVE/stray"
  printf 'x\n' > "$ARCHIVE/stray/f"
  mkdir -p "$OUTSIDE/real"
  ln -s "$OUTSIDE/real" "$ROOT/linked"

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"archived: 1   skipped: 1   removed empty: 1   restored: 1   no-archive: 1   symlinks: 1"* ]]
  [[ "$output" == *"reclaimed: 0   replaced: 0   beside: 0   unresolved: 0"* ]]
}

# =========================================================
# The provenance record
# =========================================================

@test "the first archive of a directory carries a record of where it came from" {
  make_dir old 30

  run_archive
  [ "$status" -eq 0 ]

  record="$(gtar -xJOf "$ARCHIVE/old.tar.xz" old/.archive-info)"
  grep -Eq '^archived:  [0-9]{4}-[0-9]{2}-[0-9]{2}$' <<< "$record"
  grep -qx 'directory: old' <<< "$record"
  grep -qx 'archive:   old.tar.xz' <<< "$record"
  grep -qx 'reason:    first archive of this directory' <<< "$record"
}

@test "a replaced archive keeps the record of the earlier one" {
  collide_with_changed_copy

  run_with_answers "r"
  [ "$status" -eq 0 ]

  record="$(gtar -xJOf "$ARCHIVE/old.tar.xz" old/.archive-info)"
  [ "$(grep -c '^archived: ' <<< "$record")" -eq 2 ]
  [ -z "$(sed -n 5p <<< "$record")" ]
  grep -qx 'reason:    first archive of this directory' <<< "$record"
  grep -q '^reason:    replaces the archive of the same name; content changed [0-9]*, metadata changed [0-9]*, added 1, removed 0$' <<< "$record"
}

# One path of each kind. The archive holds a, b and c. a has other content
# under its own stamp, b only another mtime, c is gone and d is new. The
# directory itself is not counted, so the prompt reads 2 changed, 1 removed, and
# the record names the two changes separately.
@test "the reason of a replace names the content and metadata changes the prompt adds up" {
  make_archive_of old a b c
  make_files "$ROOT/old" a b d
  printf 'other\n' > "$ROOT/old/a"
  touch -t "$(stamp_days_ago 20)" "$ROOT/old/a"
  touch -t "$(stamp_days_ago 25)" "$ROOT/old/b"

  run_with_answers "r"
  [ "$status" -eq 0 ]
  [[ "$output" == *"replacing discards content kept nowhere else: 2 changed, 1 removed"* ]]

  record="$(gtar -xJOf "$ARCHIVE/old.tar.xz" old/.archive-info)"
  grep -qx 'reason:    replaces the archive of the same name; content changed 1, metadata changed 1, added 1, removed 1' <<< "$record"
}

@test "an archive kept beside another records the overlap that led to it" {
  collide_with_changed_copy

  run_with_answers "s -"
  [ "$status" -eq 0 ]

  beside=("$ARCHIVE"/old.????-??-??.tar.xz)
  record="$(gtar -xJOf "${beside[0]}" old/.archive-info)"
  grep -qx "reason:    kept beside old.tar.xz, which shares the directory name at 80% path overlap" <<< "$record"
}

# =========================================================
# Names that are already taken
# =========================================================

# "x.1.tar.xz" is the plain archive name of the directory x.1 and holds x.
@test "a directory goes beside an archive of another directory that has its plain name" {
  make_unlisted_archive x
  mv "$ARCHIVE/x.tar.xz" "$ARCHIVE/x.1.tar.xz"
  make_dir x.1 30

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" =~ archiving\ \ \ \ \ \ x\.1\.[0-9]{4}-[0-9]{2}-[0-9]{2} ]]

  [ ! -e "$ROOT/x.1" ]
  [ "$(gtar -tJf "$ARCHIVE/x.1.tar.xz" | head -n 1)" = "x/" ]
  beside=("$ARCHIVE"/x.1.????-??-??.tar.xz)
  [ "$(gtar -tJf "${beside[0]}" | head -n 1)" = "x.1/" ]
}

# =========================================================
# Writing an archive
# =========================================================

@test "a failing compression keeps the original and leaves no archive" {
  make_dir old 30
  stub_xz_failing_on_compress

  run_archive
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: compression failed for old"* ]]
  [[ "$output" != *"validation failed"* ]]

  [ "$(cat "$ROOT/old/a.txt")" = "alpha" ]
  [ "$(cat "$ROOT/old/sub/b.txt")" = "beta" ]
  [ ! -e "$ARCHIVE/old.tar.xz" ]
  [ ! -e "$ARCHIVE/old.tar.xz.part" ]
}

# The record is written into the directory before the archive exists. When no
# archive comes out of the run, the directory is as it was.
@test "a failing compression leaves no record in a directory that had none" {
  make_dir old 30
  stub_xz_failing_on_compress

  run_archive
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: compression failed for old"* ]]

  [ ! -e "$ROOT/old/.archive-info" ]
  [ ! -e "$ROOT/old/.archive-info.new" ]
}

@test "a failing compression restores the earlier record with its mode and mtime" {
  make_dir old 30
  plant_earlier_record
  before="$(file_state "$ROOT/old/.archive-info")"
  stub_xz_failing_on_compress

  run_archive
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: compression failed for old"* ]]

  [ "$(file_state "$ROOT/old/.archive-info")" = "$before" ]
}

@test "a failing validation restores the earlier record with its mode and mtime" {
  make_dir old 30
  plant_earlier_record
  before="$(file_state "$ROOT/old/.archive-info")"
  stub_gtar_dropping_a_listing_line

  run_archive
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: validation failed for old"* ]]

  [ "$(file_state "$ROOT/old/.archive-info")" = "$before" ]
}

@test "runs that fail twice leave the earlier record alone" {
  make_dir old 30
  plant_earlier_record
  before="$(file_state "$ROOT/old/.archive-info")"
  stub_xz_failing_on_compress

  run_archive
  [ "$status" -eq 1 ]
  run_archive
  [ "$status" -eq 1 ]

  [ "$(file_state "$ROOT/old/.archive-info")" = "$before" ]
}

@test "a run ended by SIGTERM restores the earlier record" {
  make_dir old 30
  plant_earlier_record
  before="$(file_state "$ROOT/old/.archive-info")"
  stub_xz_terminating_the_script_on_compress

  run_archive
  [ "$status" -eq 143 ]

  [ "$(file_state "$ROOT/old/.archive-info")" = "$before" ]
  [ ! -e "$ARCHIVE/old.tar.xz" ]
}

# What the run keeps while the archive is not in place is gone again once it is.
@test "a successful run keeps the record in the archive and leaves no held copy" {
  make_dir old 30
  plant_earlier_record
  # shellcheck disable=SC2030,SC2031 # every test runs in a shell of its own
  export TMPDIR="$BATS_TEST_TMPDIR/tmp"
  mkdir "$TMPDIR"

  run_archive
  [ "$status" -eq 0 ]

  record="$(gtar -xJOf "$ARCHIVE/old.tar.xz" old/.archive-info)"
  [ "$(grep -c '^archived: ' <<< "$record")" -eq 2 ]
  [ -z "$(ls -A "$TMPDIR")" ]
}

@test "a record that cannot be put back is reported and the held copy is removed" {
  make_dir old 30
  plant_earlier_record
  # shellcheck disable=SC2030,SC2031 # every test runs in a shell of its own
  export TMPDIR="$BATS_TEST_TMPDIR/tmp"
  mkdir "$TMPDIR"
  stub_xz_failing_on_compress
  stub_cp_failing_on_the_record

  run_archive
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: compression failed for old"* ]]
  [[ "$output" == *"could not restore $ROOT/old/.archive-info"* ]]

  [ -z "$(ls -A "$TMPDIR")" ]
}

@test "a replace leaves neither a part file nor the superseded archive" {
  collide_with_changed_copy

  run_with_answers "r"
  [ "$status" -eq 0 ]

  [ "$(ls "$ARCHIVE")" = "$(printf 'index\nold.tar.xz')" ]
}
