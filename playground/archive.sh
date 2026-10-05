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
#
# A name can be claimed by more than one archive. Retrieving a directory from
# storage puts it back under a name that already has an archive, and tar
# restores mtimes, so the retrieved copy is immediately eligible again. That
# collision is resolved by comparing content, not by refusing to run. See
# handle_collision().

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

# Provenance record carried inside every archive this script writes. It
# survives extraction, so an archive that comes back out of storage explains
# where it came from without anyone having to guess from the filename.
INFO_FILE=.archive-info

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# Counters for the closing summary.
n_archived=0
n_skipped=0
n_emptied=0
n_restored=0
n_no_archive=0
n_reclaimed=0
n_replaced=0
n_beside=0
n_conflict=0

# =========================================================
# Helpers
# =========================================================

log()  { printf '%s\n' "$*"; }
warn() { printf '%s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Bold yellow, only when stdout is a terminal, so redirected/piped logs stay
# plain text instead of filling with escape codes.
if [ -t 1 ]; then
  highlight() { printf '\033[1;33m%s\033[0m\n' "$*"; }
else
  highlight() { printf '%s\n' "$*"; }
fi

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
# Comparing a directory against an existing archive
# =========================================================

# The directory an archive holds, read from the archive itself.
#
# Only the first member is needed, and cutting the decompressor off there
# keeps this fast on archives of several gigabytes. An unreadable archive
# yields an empty name.
archive_root() {
  { gtar -tJf "$1" 2>/dev/null || true; } | gsed -n '1{s:/.*::;p;q}'
}

# Every archive of a given directory: the plain <name>.tar.xz plus any
# <name>.<suffix>.tar.xz placed beside it by an earlier conflict.
#
# The filename alone cannot decide this because directory names may contain
# dots. "x.1.tar.xz" is the plain archive of a directory "x.1" or an archive
# of "x" kept beside under the suffix "1", and the glob for "x" matches both.
# Each candidate is therefore attributed by the directory it holds.
archives_for() {
  local name="$1" archive
  for archive in "$ARCHIVE_DIR/$name.tar.xz" "$ARCHIVE_DIR/$name."*".tar.xz"; do
    if [ -e "$archive" ] && [ "$(archive_root "$archive")" = "$name" ]; then
      printf '%s\n' "$archive"
    fi
  done
}

# Up to three entries from a path list, relative to the directory itself, so
# the report names what changed rather than only counting it.
samples() {
  awk -v prefix="$2/" '
    index($0, prefix) == 1 { $0 = substr($0, length(prefix) + 1) }
    $0 == "" { next }
    n < 3 { printf "%s%s", sep, $0; sep = ", "; n++ }
    END { print "" }
  ' "$1"
}

# Difference between a directory and one archive, left in the CMP_* globals.
#
# Two decompression passes rather than unpacking once to scratch space: the
# listing and the content check each need the whole stream, and these archives
# reach hundreds of megabytes compressed.
#
# tar --compare writes its differences to stdout unprefixed and its warnings
# about members missing from disk to stderr, so dropping stderr leaves exactly
# the paths that exist on both sides and disagree.
#
# In the C locale GNU tar prints non-ASCII bytes as octal escapes, which would
# never match the raw names find prints. --quoting-style=literal keeps both
# sides byte-identical.
compare_tree() {
  local archive="$1" name="$2"
  local tmp
  tmp="$(mktemp -d)"

  LC_ALL=C gtar --quoting-style=literal -tJf "$archive" \
    | gsed 's:/$::' \
    | awk -v root="$name" '$0 != root' \
    | LC_ALL=C sort -u > "$tmp/arch"
  ( cd "$ROOT" && find "$name" | awk -v root="$name" '$0 != root' | LC_ALL=C sort -u ) \
    > "$tmp/disk"

  LC_ALL=C comm -13 "$tmp/arch" "$tmp/disk" > "$tmp/only_disk"
  LC_ALL=C comm -23 "$tmp/arch" "$tmp/disk" > "$tmp/only_arch"
  LC_ALL=C comm -12 "$tmp/arch" "$tmp/disk" > "$tmp/common"

  LC_ALL=C gtar --quoting-style=literal --compare -Jf "$archive" -C "$ROOT" > "$tmp/diff" 2>/dev/null || true

  gsed -n 's/^\(.*\): \(Contents differ\|Size differs\)$/\1/p' \
    "$tmp/diff" | LC_ALL=C sort -u > "$tmp/content_all"
  gsed -n 's/^\(.*\): \(Mod time differs\|Mode differs\|Uid differs\|Gid differs\)$/\1/p' \
    "$tmp/diff" | LC_ALL=C sort -u > "$tmp/meta_reported"

  # Restricted to paths both sides have, so every difference counted here is
  # one of the CMP_COMMON entries and the four categories stay a partition.
  LC_ALL=C comm -12 "$tmp/content_all" "$tmp/common" > "$tmp/content"
  LC_ALL=C comm -12 "$tmp/meta_reported" "$tmp/common" > "$tmp/meta_all"
  # A path whose content differs also reports a mtime difference. Counting it
  # once, as content, keeps the two figures from overlapping.
  LC_ALL=C comm -23 "$tmp/meta_all" "$tmp/content" > "$tmp/meta"

  CMP_ARCHIVE="$archive"
  CMP_ONLY_DISK="$(wc -l < "$tmp/only_disk" | tr -d ' ')"
  CMP_ONLY_ARCH="$(wc -l < "$tmp/only_arch" | tr -d ' ')"
  CMP_COMMON="$(wc -l < "$tmp/common" | tr -d ' ')"
  CMP_CONTENT="$(wc -l < "$tmp/content" | tr -d ' ')"
  CMP_META="$(wc -l < "$tmp/meta" | tr -d ' ')"
  CMP_IDENTICAL=$((CMP_COMMON - CMP_CONTENT - CMP_META))
  CMP_ARCH_ENTRIES=$((CMP_COMMON + CMP_ONLY_ARCH))
  CMP_DISK_ENTRIES=$((CMP_COMMON + CMP_ONLY_DISK))

  # The overlap is over the union of both trees, so a directory that merely
  # grew scores lower than one that is unchanged. That is intended: growth is
  # evidence of work, which is what the question is really about.
  local union=$((CMP_COMMON + CMP_ONLY_DISK + CMP_ONLY_ARCH))
  CMP_UNION="$union"
  if [ "$union" -eq 0 ]; then
    CMP_OVERLAP=100
  else
    CMP_OVERLAP=$((CMP_COMMON * 100 / union))
  fi

  CMP_SAMPLE_CONTENT="$(samples "$tmp/content" "$name")"
  CMP_SAMPLE_META="$(samples "$tmp/meta" "$name")"
  CMP_SAMPLE_ONLY_DISK="$(samples "$tmp/only_disk" "$name")"
  CMP_SAMPLE_ONLY_ARCH="$(samples "$tmp/only_arch" "$name")"

  rm -rf "$tmp"
}

# The directory reproduces the archive exactly, so the archive already holds
# everything the directory does.
cmp_is_identical() {
  [ "$CMP_ONLY_DISK" -eq 0 ] \
    && [ "$CMP_ONLY_ARCH" -eq 0 ] \
    && [ "$CMP_CONTENT" -eq 0 ] \
    && [ "$CMP_META" -eq 0 ]
}

# =========================================================
# Reporting a collision
# =========================================================

# How much of the archive's tree is still recognisable on disk. The bands are
# a reading aid for the person answering the prompt, not a decision: a tree
# retrieved and then heavily reworked can land anywhere on this scale.
cmp_verdict() {
  if [ "$CMP_OVERLAP" -ge 60 ]; then
    printf 'modified copy of this archive'
  elif [ "$CMP_OVERLAP" -lt 20 ]; then
    printf 'unrelated directory sharing the name'
  else
    printf 'unclear, inspect before deciding'
  fi
}

# One line of the difference breakdown. Names are only worth printing for a
# category that has any.
stat_line() {
  if [ -z "$3" ]; then
    printf '    %s  %s\n' "$1" "$2"
  else
    printf '    %s  %s   %s\n' "$1" "$2" "$3"
  fi
}

report_collision() {
  local name="$1" n_archives="$2"
  local disk_size arch_size arch_date

  disk_size="$(du -sh "$ROOT/$name" | cut -f1)"
  arch_size="$(du -h "$CMP_ARCHIVE" | cut -f1)"
  arch_date="$(date -r "$CMP_ARCHIVE" +%Y-%m-%d)"

  log ""
  highlight ">>> $name already has an archive <<<"
  log "  archive    $(basename "$CMP_ARCHIVE")"
  log "             $arch_date   $arch_size   $CMP_ARCH_ENTRIES entries"
  log "  on disk    $disk_size   $CMP_DISK_ENTRIES entries"
  log "  overlap    $CMP_COMMON/$CMP_UNION paths (${CMP_OVERLAP}%)"
  if [ "$n_archives" -gt 1 ]; then
    log "             closest of $n_archives archives on this name"
  fi
  log ""
  stat_line "identical       " "$CMP_IDENTICAL"  ""
  stat_line "content differs " "$CMP_CONTENT"    "$CMP_SAMPLE_CONTENT"
  stat_line "metadata differs" "$CMP_META"       "$CMP_SAMPLE_META"
  stat_line "only on disk    " "$CMP_ONLY_DISK"  "$CMP_SAMPLE_ONLY_DISK"
  stat_line "only in archive " "$CMP_ONLY_ARCH"  "$CMP_SAMPLE_ONLY_ARCH"
  log ""
  log "  reads as: $(cmp_verdict)"
}

# =========================================================
# Naming a second archive
# =========================================================

# Archives beside an existing one are named <dir>.<archive-date>.tar.xz, which
# groups them with the original in a listing and says when the second copy
# showed up. Two collisions on one name on one day get a counter so the script
# never has a reason to overwrite.
default_suffix() {
  local name="$1" today n=2 candidate
  today="$(date +%Y-%m-%d)"

  candidate="$today"
  while [ -e "$ARCHIVE_DIR/$name.$candidate.tar.xz" ]; do
    candidate="$today-$n"
    n=$((n + 1))
  done
  printf '%s\n' "$candidate"
}

# Suffixes are limited to letters, digits, underscore and hyphen, which keeps
# path separators out of the archive name. Which directory an archive belongs
# to is read from its contents (see archives_for), not parsed from the name.
valid_suffix() {
  case "$1" in
    ""|*[!A-Za-z0-9_-]*) return 1 ;;
    *) return 0 ;;
  esac
}

# =========================================================
# Archiving
# =========================================================

# Appended to, never replaced, so a directory that has been archived,
# retrieved and archived again carries the whole chain.
write_archive_info() {
  local name="$1" target="$2" reason="$3"
  local info="$ROOT/$name/$INFO_FILE"

  {
    if [ -e "$info" ]; then
      cat "$info"
      printf '\n'
    fi
    printf 'archived:  %s\n' "$(date +%Y-%m-%d)"
    printf 'directory: %s\n' "$name"
    printf 'archive:   %s\n' "$(basename "$target")"
    printf 'reason:    %s\n' "$reason"
  } > "$info.new"
  mv "$info.new" "$info"

  # Stamped at the cutoff so the record itself never counts as recent activity.
  # A retrieved directory is then eligible on exactly the same terms as one
  # that has never been archived.
  touch -r "$CUTOFF_REF" "$info"
}

# Compress $ROOT/<name> to the given archive path and delete the original.
#
# The original outlives every step that could fail. An existing archive at the
# target is moved aside rather than deleted, and only dropped once the
# replacement is in place, so no window exists in which the name has no
# archive behind it.
archive_dir() {
  local name="$1" target="$2" reason="$3"
  local src="$ROOT/$name"
  local part="$target.part"
  local superseded="$target.superseded"

  if [ "$DRY_RUN" -eq 1 ]; then
    return 0
  fi

  write_archive_info "$name" "$target" "$reason"

  rm -f "$part"
  if ! gtar --sort=name -cf - -C "$ROOT" "$name" | xz "${XZ_OPTS[@]}" -c > "$part"; then
    rm -f "$part"
    die "compression failed for $name"
  fi

  if ! validate_archive "$part" "$src" "$name"; then
    rm -f "$part"
    die "validation failed for $name; original left untouched"
  fi

  if [ -e "$target" ]; then
    mv "$target" "$superseded"
    mv "$part" "$target"
    rm -f "$superseded"
  else
    mv "$part" "$target"
  fi

  rm -rf "$src"
}

# =========================================================
# Resolving a collision
# =========================================================

# Prompting reads /dev/tty rather than stdin so the script still asks when its
# output is being piped to a log. Without a terminal there is nobody to ask,
# and the conflict is reported and left alone.
can_prompt() {
  [ "$DRY_RUN" -eq 0 ] || return 1
  [ -c /dev/tty ] || return 1
  { : < /dev/tty; } 2>/dev/null || return 1
  return 0
}

# Replacing is lossy exactly when the archive holds something the directory no
# longer does. A directory that only grew loses nothing.
replace_cost() {
  local lost=$((CMP_CONTENT + CMP_META))
  if [ "$lost" -eq 0 ] && [ "$CMP_ONLY_ARCH" -eq 0 ]; then
    printf 'replacing loses nothing: the directory contains everything the archive does'
  else
    printf 'replacing discards content kept nowhere else: %s changed, %s removed' \
      "$lost" "$CMP_ONLY_ARCH"
  fi
}

ask_resolution() {
  local name="$1"
  local suffix answer

  suffix="$(default_suffix "$name")"

  log ""
  log "  $(replace_cost)"
  log ""
  log "  [r] replace $(basename "$CMP_ARCHIVE")"
  log "  [s] archive beside it as $name.$suffix.tar.xz"
  log "  [k] skip, leave the directory and the archive as they are"

  while :; do
    printf '  choice [r/s/k]: '
    if ! read -r answer < /dev/tty; then
      log ""
      RESOLUTION=skip
      return 0
    fi
    case "$answer" in
      r|R)
        RESOLUTION=replace
        return 0
        ;;
      s|S)
        while :; do
          printf '  suffix [%s]: ' "$suffix"
          if ! read -r answer < /dev/tty; then
            answer=""
          fi
          [ -n "$answer" ] || break
          if ! valid_suffix "$answer"; then
            warn "  suffix may only contain letters, digits, underscore and hyphen"
            continue
          fi
          if [ -e "$ARCHIVE_DIR/$name.$answer.tar.xz" ]; then
            warn "  $name.$answer.tar.xz already exists"
            continue
          fi
          suffix="$answer"
          break
        done
        RESOLUTION=beside
        RESOLUTION_SUFFIX="$suffix"
        return 0
        ;;
      k|K)
        RESOLUTION=skip
        return 0
        ;;
      *)
        warn "  answer r, s or k"
        ;;
    esac
  done
}

# A directory whose name is already taken by at least one archive.
#
# Identical content needs no decision: the archive is proof that nothing would
# be lost, so the working copy goes and the archive stays. Anything else is
# the user's call, made against the numbers in the report.
handle_collision() {
  local name="$1"
  shift
  local n_archives=$#
  local archive best="" best_overlap=-1

  for archive in "$@"; do
    compare_tree "$archive" "$name"
    if cmp_is_identical; then
      if [ "$DRY_RUN" -eq 1 ]; then
        log "would reclaim  $name (identical to $(basename "$archive"))"
      else
        log "reclaiming     $name (identical to $(basename "$archive"))"
        rm -rf "${ROOT:?}/${name:?}"
      fi
      n_reclaimed=$((n_reclaimed + 1))
      return 0
    fi
    if [ "$CMP_OVERLAP" -gt "$best_overlap" ]; then
      best="$archive"
      best_overlap="$CMP_OVERLAP"
    fi
  done

  # The loop leaves CMP_* describing whichever archive it saw last.
  if [ "$CMP_ARCHIVE" != "$best" ]; then
    compare_tree "$best" "$name"
  fi

  report_collision "$name" "$n_archives"

  if ! can_prompt; then
    log ""
    if [ "$DRY_RUN" -eq 1 ]; then
      log "  dry run: $name left in place"
    else
      warn "  no terminal to ask on: $name left in place"
    fi
    n_conflict=$((n_conflict + 1))
    return 0
  fi

  RESOLUTION=""
  RESOLUTION_SUFFIX=""
  ask_resolution "$name"

  case "$RESOLUTION" in
    replace)
      log "replacing      $(basename "$best")"
      archive_dir "$name" "$best" \
        "replaces the archive of the same name; changed $CMP_CONTENT, added $CMP_ONLY_DISK, removed $CMP_ONLY_ARCH"
      n_replaced=$((n_replaced + 1))
      ;;
    beside)
      log "archiving      $name.$RESOLUTION_SUFFIX"
      archive_dir "$name" "$ARCHIVE_DIR/$name.$RESOLUTION_SUFFIX.tar.xz" \
        "kept beside $(basename "$best"), which shares the directory name at ${CMP_OVERLAP}% path overlap"
      n_beside=$((n_beside + 1))
      ;;
    *)
      log "skipping       $name"
      n_conflict=$((n_conflict + 1))
      ;;
  esac
}

# =========================================================
# Main
# =========================================================

command -v gtar >/dev/null || die "gtar (GNU tar) is required"
command -v gsed >/dev/null || die "gsed (GNU sed) is required"
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
[ "$DRY_RUN" -eq 1 ] && log "(dry run, nothing will be written or deleted)"
log ""

for path in "$ROOT"/*/; do
  name="$(basename "$path")"
  [ "$name" = "archive" ] && continue

  # A .no-archive marker is an explicit opt-out, checked before anything
  # else so it also protects otherwise-empty or aged-out directories.
  if [ -e "$path.no-archive" ]; then
    highlight ">>> $name skipped: .no-archive present <<<"
    n_no_archive=$((n_no_archive + 1))
    continue
  fi

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
    continue
  fi

  existing=()
  while IFS= read -r archive; do
    existing+=("$archive")
  done < <(archives_for "$name")

  if [ "${#existing[@]}" -eq 0 ]; then
    # The plain name can already be taken by an archive of another directory
    # kept beside its own under a suffix: "x.1.tar.xz" holding "x" when "x.1"
    # comes up. archive_dir would replace it, so this directory goes beside it
    # under a suffix instead.
    target="$ARCHIVE_DIR/$name.tar.xz"
    if [ -e "$target" ]; then
      target="$ARCHIVE_DIR/$name.$(default_suffix "$name").tar.xz"
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      log "would archive  $(basename "$target" .tar.xz)"
    else
      log "archiving      $(basename "$target" .tar.xz)"
    fi
    archive_dir "$name" "$target" "first archive of this directory"
    n_archived=$((n_archived + 1))
  else
    handle_collision "$name" "${existing[@]}"
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
log "archived: $n_archived   skipped: $n_skipped   removed empty: $n_emptied   restored: $n_restored   no-archive: $n_no_archive"
log "reclaimed: $n_reclaimed   replaced: $n_replaced   beside: $n_beside   unresolved: $n_conflict"

# An unresolved collision is work the run could not finish, which matters to
# whatever scheduled it.
[ "$n_conflict" -eq 0 ] || exit 1
