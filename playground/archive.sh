#!/usr/bin/env bash
#
# Archive aged-out playground working directories into archive/.
#
# Each directory becomes archive/<name>.tar.xz. A directory is eligible once
# every file beneath it is older than AGE_DAYS, i.e. its most recently modified
# file predates the cutoff. Naming plays no part in the decision.
#
# Originals are removed only after the archive has been proven to reproduce
# them exactly. See validate_archive() for what "proven" means here.

set -euo pipefail

# =========================================================
# Configuration
# =========================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_DIR="$ROOT/archive"
AGE_DAYS=14

# xz -9 gives a 64 MiB dictionary, which measured within 1% of every
# alternative on this corpus. SHA-256 rather than the default CRC64 because
# it is the checksum the deletion step relies on.
XZ_OPTS=(-T0 -9 --check=sha256)

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# Counters for the closing summary.
n_archived=0
n_skipped=0
n_emptied=0
n_restored=0

# =========================================================
# Helpers
# =========================================================

log()  { printf '%s\n' "$*"; }
warn() { printf '%s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Absolute cutoff as YYYYMMDD. GNU date and BSD date disagree on how to do
# relative dates, and both are plausible on this machine depending on whether
# coreutils shadows the system binary.
cutoff_date() {
  date -d "$AGE_DAYS days ago" +%Y%m%d 2>/dev/null \
    || date -v-"$AGE_DAYS"d +%Y%m%d
}

# Whether any file beneath the directory was modified after the cutoff.
#
# The comparison runs through find -newer against a reference file stamped at
# the cutoff, rather than reading each mtime and comparing numbers: -printf
# '%T@' is GNU-only and `stat` takes incompatible flags on the two platforms,
# whereas -newer behaves the same everywhere. -print -quit also lets find stop
# at the first recent file instead of walking the whole tree.
has_recent_file() {
  [ -n "$(find "$1" -type f -newer "$CUTOFF_REF" -print -quit)" ]
}

# A directory counts as empty when it holds no files anywhere beneath it,
# even if it contains a skeleton of subdirectories.
is_empty_tree() {
  [ -z "$(find "$1" -type f -print -quit)" ]
}

# =========================================================
# Validation
# =========================================================

# Three independent checks, each covering a failure the others miss:
#
#   1. xz -t proves the stream decompresses and matches its stored SHA-256,
#      i.e. the archive is not truncated or corrupt.
#   2. tar --compare diffs every archived member against the filesystem, so
#      content or metadata drift is caught.
#   3. The entry count catches the one case --compare structurally cannot:
#      a file present on disk that never made it into the archive, since
#      --compare only ever walks members the archive already contains.
#
# Only if all three pass is the original safe to delete.
validate_archive() {
  local archive="$1" src_dir="$2" name="$3"

  xz -t "$archive" || return 1

  gtar --compare -Jf "$archive" -C "$ROOT" || return 1

  local n_disk n_arch
  n_disk="$(find "$src_dir" | wc -l | tr -d ' ')"
  n_arch="$(gtar -tJf "$archive" | wc -l | tr -d ' ')"
  if [ "$n_disk" -ne "$n_arch" ]; then
    warn "entry count mismatch for $name: disk=$n_disk archive=$n_arch"
    return 1
  fi

  return 0
}

# =========================================================
# Archiving
# =========================================================

archive_dir() {
  local name="$1"
  local src="$ROOT/$name"
  local target="$ARCHIVE_DIR/$name.tar.xz"
  local part="$target.part"

  # A name collision means two different directories are claiming the same
  # archive slot. That is never routine, so stop rather than guess.
  [ -e "$target" ] && die "archive already exists: $target"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "would archive  $name"
    n_archived=$((n_archived + 1))
    return 0
  fi

  log "archiving      $name"

  # Written to .part first so an interrupted run cannot leave behind
  # something that looks like a finished archive.
  rm -f "$part"
  if ! gtar --sort=name -cf - -C "$ROOT" "$name" | xz "${XZ_OPTS[@]}" -c > "$part"; then
    rm -f "$part"
    die "compression failed for $name"
  fi
  mv "$part" "$target"

  if ! validate_archive "$target" "$src" "$name"; then
    rm -f "$target"
    die "validation failed for $name; original left untouched"
  fi

  rm -rf "$src"
  n_archived=$((n_archived + 1))
}

# =========================================================
# Main
# =========================================================

command -v gtar >/dev/null || die "gtar (GNU tar) is required"
command -v xz   >/dev/null || die "xz is required"
[ -d "$ARCHIVE_DIR" ] || die "archive directory not found: $ARCHIVE_DIR"

CUTOFF="$(cutoff_date)"

# The reference file every directory's contents are compared against. It lives
# outside the tree being scanned so that it cannot be mistaken for a candidate,
# and is stamped at midnight of the cutoff day.
CUTOFF_REF="$(mktemp)"
trap 'rm -f "$CUTOFF_REF"' EXIT
touch -t "${CUTOFF}0000" "$CUTOFF_REF"

log "cutoff: directories untouched since $CUTOFF are archived"
[ "$DRY_RUN" -eq 1 ] && log "(dry run — nothing will be written or deleted)"
log ""

for path in "$ROOT"/*/; do
  name="$(basename "$path")"
  [ "$name" = "archive" ] && continue

  # Empty trees carry no information worth compressing.
  if is_empty_tree "$path"; then
    if [ "$DRY_RUN" -eq 1 ]; then
      log "would remove   $name (empty)"
    else
      log "removing       $name (empty)"
      rm -rf "${path:?}"
    fi
    n_emptied=$((n_emptied + 1))
    continue
  fi

  if has_recent_file "$path"; then
    n_skipped=$((n_skipped + 1))
  else
    archive_dir "$name"
  fi
done

# Directories that ended up inside archive/ uncompressed are moved back out.
# They are deliberately not archived in this same run: the move restores them
# to the normal population, and the next run treats them like any other
# directory.
for path in "$ARCHIVE_DIR"/*/; do
  [ -e "$path" ] || continue
  name="$(basename "$path")"
  if [ -e "$ROOT/$name" ]; then
    warn "cannot restore $name: a directory of that name already exists"
    continue
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    log "would restore  $name (uncompressed, from archive/)"
  else
    log "restoring      $name (uncompressed, from archive/)"
    mv "$path" "$ROOT/$name"
  fi
  n_restored=$((n_restored + 1))
done

log ""
log "archived: $n_archived   skipped: $n_skipped   removed empty: $n_emptied   restored: $n_restored"
