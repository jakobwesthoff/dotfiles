# shellcheck shell=bash
#
# Fixtures for the retrieve preview tests (preview.bats).

# A directory in PATH whose gtar appends the arguments of every call to
# $GTAR_CALLS and then runs the real one, so a test can tell which archive
# reads the preview made. The log is emptied here: install the shim after the
# fixture is built, since building an archive and its listing calls gtar too.
#
# The log is a plain file and never fd 9, which carries the coverage trace.
stub_gtar_logging_calls() {
  local real stub="$BATS_TEST_TMPDIR/stub-preview"
  GTAR_CALLS="$BATS_TEST_TMPDIR/gtar-calls"
  : > "$GTAR_CALLS"
  real="$(command -v gtar)"
  mkdir -p "$stub"
  cat > "$stub/gtar" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$GTAR_CALLS"
exec "$real" "\$@"
EOF
  chmod +x "$stub/gtar"
  PATH="$stub:$PATH"
}

# Replaces the listing of an archive of the directory "old" with <lines> lines
# in the format of tar -tv: the directory itself, its .archive-info, then
# members named "LISTED 001", "LISTED 002" ... that no archive holds, so output
# containing them came from the listing. The owner/group field is the third
# argument.
write_sentinel_listing() {
  local archive="$1" lines="$2" owner="${3:-user/group}" i
  # shellcheck disable=SC2153 # ARCHIVE is set by setup_root in helpers.bash
  mkdir -p "$ARCHIVE/index"
  {
    printf 'drwxr-xr-x %s 0 2026-01-01 12:00 old/\n' "$owner"
    printf -- '-rw-r--r-- %s 40 2026-01-01 12:00 old/.archive-info\n' "$owner"
    for ((i = 1; i <= lines - 2; i++)); do
      printf -- '-rw-r--r-- %s 1 2026-01-01 12:00 old/LISTED %03d\n' "$owner" "$i"
    done
  } > "$ARCHIVE/index/$archive.lst"
}
