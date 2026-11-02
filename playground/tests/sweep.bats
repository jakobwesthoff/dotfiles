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

  run_archive
  [ "$status" -eq 0 ]
  [[ "$output" == *"archived: 1   skipped: 1   removed empty: 1   restored: 1   no-archive: 1"* ]]
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
