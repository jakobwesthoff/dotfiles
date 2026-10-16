#!/usr/bin/env bash
#
# Mirror the playground onto the timecapsule dataset of the NAS zocalo.
#
# rsync runs over SSH, so the receiving rsync works on the NAS's own disks.
# Over the SMB mount every file cost several network round trips, and with the
# playground's tens of thousands of small files that kept the transfer at a
# few MB/s on a 2.5 GbE link.
#
# Every machine writes to a directory of its own, playground/<computer name>/
# on the dataset. A mirror deletes whatever the source lacks, so machines
# sharing one target would delete each other's directories on every run.
#
# Working directories are mirrored: whatever was moved, renamed or deleted
# locally is moved, renamed or deleted on the NAS too. rsync does not detect
# moves, so a moved file is deleted at its old path and uploaded again at the
# new one.
#
# archive/ is only ever added to, never pruned. The NAS is meant to keep the
# complete archive history even once the playground itself keeps only recent
# archives, and that requires a sync that never deletes an archive there.
#
# TODO: Bring the playgrounds of several machines together, once they have
# drifted apart. Each machine's mirror is kept separate until then.
#
# Usage:
#   timecapsule-sync.sh [options]
#
#   --dry-run              show what would change, change nothing
#   --force                sync even when the deletion brake trips
#   --host <host>          reach the NAS under this name or IPv4 address
#                          instead of NAS_HOST
#   --skip-network-check   sync even outside the home network

set -euo pipefail

# =========================================================
# Configuration
# =========================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The Bonjour name. It is also the name the NAS's SSH host key is recorded
# under in known_hosts.
NAS_HOST=zocalo.local
NAS_USER=jakob

# Where the timecapsule SMB share lives on the NAS, so the mirror is the same
# tree the share shows.
REMOTE_BASE=/mnt/shadow/timecapsule/playground

# The home network is recognised by its router and its /24. Over a VPN the
# NAS can be reachable as well, but a sync of gigabytes does not belong there.
HOME_GATEWAY=192.168.178.1
HOME_SUBNET_PREFIX=192.168.178.

# A mirror faithfully copies a mistake: a playground that is empty or half
# gone, say from running the wrong copy of this script, would empty the mirror
# too. A run that would delete more than this percentage of the entries on the
# NAS stops and asks first.
MAX_DELETE_PERCENT=20

# BatchMode makes a missing key or an unknown host fail at once instead of
# waiting on a password prompt nobody may be there to answer.
#
# HostKeyAlias checks the host key against the one recorded for NAS_HOST, so
# --host with an IP address or another name needs no known_hosts entry of its
# own and still cannot end up talking to a different machine.
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=5 -o "HostKeyAlias=$NAS_HOST")

DRY_RUN=0
FORCE=0
NETWORK_CHECK=1
HOST_OVERRIDE=""

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

# Prompting reads /dev/tty rather than stdin so the script still asks when its
# output is being piped to a log.
can_prompt() {
  [ -c /dev/tty ] || return 1
  { : < /dev/tty; } 2>/dev/null || return 1
  return 0
}

# =========================================================
# Finding the NAS
# =========================================================

is_ipv4() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# dscacheutil goes through the system resolver, which answers unicast DNS
# names and Bonjour .local names alike. It prints nothing for a name that does
# not resolve.
resolve_ipv4() {
  if is_ipv4 "$1"; then
    printf '%s\n' "$1"
    return 0
  fi
  dscacheutil -q host -a name "$1" | awk '$1 == "ip_address:" { print $2; exit }'
}

default_gateway() {
  route -n get default 2>/dev/null | awk '$1 == "gateway:" { print $2; exit }'
}

# Settles which address the NAS is reached at, leaves it in NAS_HOST and
# NAS_IP, and refuses outside the home network unless told otherwise.
find_nas() {
  [ -z "$HOST_OVERRIDE" ] || NAS_HOST="$HOST_OVERRIDE"

  if [ "$NETWORK_CHECK" -eq 1 ]; then
    local gateway
    gateway="$(default_gateway)"
    if [ "$gateway" != "$HOME_GATEWAY" ]; then
      die "not in the home network (default gateway ${gateway:-none}, expected $HOME_GATEWAY); pass --skip-network-check to sync anyway"
    fi
  fi

  NAS_IP="$(resolve_ipv4 "$NAS_HOST")"
  [ -n "$NAS_IP" ] || die "$NAS_HOST does not resolve"

  if [ "$NETWORK_CHECK" -eq 1 ] && [[ "$NAS_IP" != "$HOME_SUBNET_PREFIX"* ]]; then
    die "$NAS_HOST is $NAS_IP, outside the home network ${HOME_SUBNET_PREFIX}0/24; pass --skip-network-check to sync anyway"
  fi

  # A closed port is told apart from a failing login: one means the NAS is
  # away, the other that SSH needs fixing.
  nc -z -G 2 "$NAS_IP" 22 >/dev/null 2>&1 || die "$NAS_HOST ($NAS_IP) does not answer on port 22"
}

# The mirror's parent directory is created by hand, once. Its absence means
# the dataset is not where REMOTE_BASE says, and nothing is written then.
check_remote_base() {
  local rc=0
  # The path is meant to expand locally; %q quotes it for the remote shell.
  # shellcheck disable=SC2029
  ssh "${SSH_OPTS[@]}" "$NAS_USER@$NAS_HOST" "test -d $(printf '%q' "$REMOTE_BASE")" || rc=$?
  case "$rc" in
    0) return 0 ;;
    255) die "ssh to $NAS_USER@$NAS_HOST failed" ;;
    *) die "$REMOTE_BASE not found on $NAS_HOST" ;;
  esac
}

# =========================================================
# What the sync transfers
# =========================================================

# -rlt rather than -a: files on the NAS take the dataset's permissions, the
# same ones the SMB share gives to files written through it, so access over
# the share works the same for every file whichever way it arrived.
#
# Filter rules are first-match:
#
#   P protects the archives in archive/ on the NAS from deletion, which is
#     what keeps archive/ additive while the rest is mirrored.
#   .DS_Store is Finder state, not playground content.
#   archive/ sends only finished archives. archive.sh leaves .part and
#     .superseded files there mid-run and parks uncompressed directories there
#     until its next run.
#
# --delete-excluded removes excluded files from the NAS as well. That clears
# .DS_Store files Finder writes through the SMB share, and anything in
# archive/ that is not a finished archive, such as an interrupted transfer's
# temporary file.
RSYNC_OPTS=(
  -rlt
  --delete
  --delete-excluded
  --filter='P /archive/*.tar.xz'
  --filter='- .DS_Store'
  --filter='+ /archive/'
  --filter='+ /archive/*.tar.xz'
  --filter='- /archive/*'
)

# rsync exits 24 when files vanished between listing and transfer. The
# playground is in use while it syncs, so that is expected; the next run picks
# up whatever replaced them.
run_rsync() {
  local rc=0
  rsync -e "ssh ${SSH_OPTS[*]}" "$@" || rc=$?
  case "$rc" in
    0) return 0 ;;
    24) warn "some files vanished during the sync" ;;
    *) die "rsync failed with exit code $rc" ;;
  esac
}

# =========================================================
# Planning and the deletion brake
# =========================================================

# A dry run itemizing every entry, unchanged ones included (-ii), so the plan
# tells how many entries the NAS holds, not just how many change. Archives
# that only the NAS still has are protected and not listed, so they count
# neither as present nor as deleted.
#
# The itemize code is the first 11 characters of a line: "*deleting" for a
# deletion, nine "+" for a new entry, a "." followed only by spaces for an
# unchanged one, anything else for an update. Lines without a code, such as
# "created directory", are rsync's own messages.
plan_sync() {
  local plan_file="$1"
  local counts

  run_rsync "${RSYNC_OPTS[@]}" -n -ii "$ROOT/" "$DEST/" > "$plan_file"

  counts="$(awk '
    {
      code = substr($0, 1, 11)
      type = substr(code, 2, 1)
    }
    code ~ /^\*deleting/          { deleted++; next }
    code !~ /^[<>ch.][fdLDS]/     { next }
    index(code, "+++++++++")      { if (type != "d") added++; next }
    code ~ /^\.[fdLDS] *$/        { unchanged++; next }
                                  { if (type != "d") updated++; changed++ }
    END { printf "%d %d %d %d %d\n", added, updated, deleted, unchanged, changed }
  ' "$plan_file")"

  read -r PLAN_ADDED PLAN_UPDATED PLAN_DELETED PLAN_UNCHANGED PLAN_CHANGED <<< "$counts"

  local on_nas=$((PLAN_UNCHANGED + PLAN_CHANGED + PLAN_DELETED))
  if [ "$on_nas" -eq 0 ]; then
    PLAN_DELETE_PERCENT=0
  else
    PLAN_DELETE_PERCENT=$((PLAN_DELETED * 100 / on_nas))
  fi
  PLAN_ON_NAS="$on_nas"
}

report_plan() {
  log "plan           $PLAN_ADDED files new, $PLAN_UPDATED changed, $PLAN_DELETED entries deleted"
  log "               ($PLAN_DELETE_PERCENT% of $PLAN_ON_NAS entries on the NAS)"
}

# Whether the planned deletions may go ahead. Below the limit they always may.
# Above it a person at a terminal decides, after seeing what would go; without
# one the run stops.
deletion_allowed() {
  local plan_file="$1" answer

  [ "$PLAN_DELETE_PERCENT" -gt "$MAX_DELETE_PERCENT" ] || return 0

  log ""
  highlight ">>> $PLAN_DELETED of $PLAN_ON_NAS entries on the NAS would be deleted (limit $MAX_DELETE_PERCENT%) <<<"
  gsed -n 's/^\*deleting *//p' "$plan_file" | gsed 10q | gsed 's/^/  /'
  [ "$PLAN_DELETED" -le 10 ] || log "  ..."
  log ""

  if [ "$DRY_RUN" -eq 1 ]; then
    log "dry run: a real run would stop here and ask"
    return 0
  fi

  if ! can_prompt; then
    warn "no terminal to ask on; pass --force to sync anyway"
    return 1
  fi

  printf '  delete them anyway? [y/N]: '
  read -r answer < /dev/tty || answer=""
  case "$answer" in
    y|Y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

# =========================================================
# Sync run
# =========================================================

cmd_sync() {
  local computer

  # The computer name from System Settings is set by hand and stays put. The
  # Bonjour LocalHostName picks up a "-2" suffix on name conflicts, and the
  # plain hostname may follow DHCP, so neither is fit to name a directory.
  computer="$(scutil --get ComputerName)"
  [ -n "$computer" ] || die "no computer name set"

  find_nas
  log "NAS            $NAS_HOST ($NAS_IP)"
  check_remote_base

  DEST="$NAS_USER@$NAS_HOST:$REMOTE_BASE/$computer"
  log "syncing        $ROOT -> $DEST"
  [ "$DRY_RUN" -eq 0 ] || log "(dry run, nothing will be written or deleted)"

  # --force skips the plan entirely, since its only use outside a dry run is
  # the brake, and it walks the whole tree on both sides a second time.
  if [ "$FORCE" -eq 0 ] || [ "$DRY_RUN" -eq 1 ]; then
    PLAN_FILE="$(mktemp)"
    trap 'rm -f "$PLAN_FILE"' EXIT
    plan_sync "$PLAN_FILE"
    report_plan
    if ! deletion_allowed "$PLAN_FILE"; then
      die "sync stopped before deleting anything"
    fi
  fi

  [ "$DRY_RUN" -eq 0 ] || return 0

  local progress=()
  if [ -t 1 ]; then
    progress=(--info=progress2)
  fi

  run_rsync "${RSYNC_OPTS[@]}" "${progress[@]}" "$ROOT/" "$DEST/"
  log "synced         $DEST"
}

# =========================================================
# Main
# =========================================================

usage() {
  cat <<'EOF'
usage: timecapsule-sync.sh [--dry-run] [--force] [--host <host>] [--skip-network-check]
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    --skip-network-check) NETWORK_CHECK=0 ;;
    --host)
      [ $# -ge 2 ] || { usage >&2; exit 2; }
      HOST_OVERRIDE="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

# The Homebrew rsync is needed: the one macOS ships is openrsync, which lacks
# --info and itemizes differently.
rsync --info=help >/dev/null 2>&1 || die "rsync 3.1 or newer is required (brew install rsync)"
command -v gsed >/dev/null || die "gsed (GNU sed) is required"

# The archive directory marks a real playground. Run from the dotfiles copy
# instead of the symlink, ROOT would be dotfiles/playground, and mirroring
# that would delete the whole playground on the NAS.
[ -d "$ROOT/archive" ] || die "not a playground (no archive/ in $ROOT); run it through the symlink in the playground"

cmd_sync
