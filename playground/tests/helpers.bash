# shellcheck shell=bash
#
# Shared fixtures for the archive.sh tests.
#
# Every test gets its own ROOT in BATS_TEST_TMPDIR with a copy of archive.sh
# next to an archive/ directory, because the script derives ROOT from its own
# location. Nothing here touches the real playground.

ANSWER_EXP="$BATS_TEST_DIRNAME/answer.exp"

setup_root() {
  ROOT="$BATS_TEST_TMPDIR/root"
  mkdir -p "$ROOT/archive"
  cp "$BATS_TEST_DIRNAME/../archive.sh" "$ROOT/archive.sh"
  chmod +x "$ROOT/archive.sh"
  ARCHIVE="$ROOT/archive"
}

# A day-aged timestamp for touch -t. GNU and BSD date disagree on relative
# dates, as they do in the script itself.
stamp_days_ago() {
  { date -d "$1 days ago" +%Y%m%d1200 2>/dev/null || date -v-"$1"d +%Y%m%d1200; }
}

# A directory with two files and a subdirectory, every mtime <days> days ago.
make_dir() {
  local name="$1" days="$2"
  mkdir -p "$ROOT/$name/sub"
  printf 'alpha\n' > "$ROOT/$name/a.txt"
  printf 'beta\n' > "$ROOT/$name/sub/b.txt"
  touch_tree "$ROOT/$name" "$days"
}

touch_tree() {
  find "$1" -exec touch -t "$(stamp_days_ago "$2")" {} +
}

# Runs the script under test. With ARCHIVE_TRACE set, every executed line,
# including those of processes the script starts, is appended to that file as
# "+<script>:<line>: <command>". The trace goes to fd 9 so that it does not
# mix into the output the tests assert on. ARCHIVE_BASH picks the interpreter.
# shellcheck disable=SC2120 # called without arguments for a plain archiving run
run_archive() {
  if [ -n "${ARCHIVE_TRACE:-}" ]; then
    # shellcheck disable=SC2016 # PS4 is expanded by the traced shell
    run env SHELLOPTS=xtrace PS4='+${BASH_SOURCE}:${LINENO}: ' BASH_XTRACEFD=9 \
      "${ARCHIVE_BASH:-bash}" "$ROOT/archive.sh" "$@" 9>>"$ARCHIVE_TRACE"
  else
    run "${ARCHIVE_BASH:-bash}" "$ROOT/archive.sh" "$@"
  fi
}

# Runs the script on a terminal of its own and types the given answers at its
# prompts, one per prompt; "-" is an empty line. A test started from a
# terminal has /dev/tty, so every test that can reach a collision prompt has
# to go through here instead of run_archive.
#
# A terminal turns line ends into CRLF and makes the script colour its
# highlights, so both are stripped to leave plain text for substring checks.
run_with_answers() {
  local answers="$1"
  shift
  run bash -c '
    ANSWERS="$1" expect "$2" "${@:3}" | tr -d "\r" | gsed "s/\x1b\[[0-9;]*m//g"
    exit "${PIPESTATUS[0]}"
  ' _ "$answers" "$ANSWER_EXP" "${ARCHIVE_BASH:-bash}" "$ROOT/archive.sh" "$@"
}

# Puts back a directory from its archive without deleting the archive, so a
# test can then change it and run into the collision.
extract_from_archive() {
  gtar -xJf "$ARCHIVE/$1.tar.xz" -C "$ROOT"
}

# A directory restored from its archive and then changed, so that its name is
# taken by an archive it no longer matches.
# shellcheck disable=SC2119,SC2154 # status is set by bats' run
collide_with_changed_copy() {
  make_dir old 30
  run_archive
  [ "$status" -eq 0 ]
  extract_from_archive old
  printf 'gamma\n' > "$ROOT/old/new.txt"
  touch_tree "$ROOT/old" 30
}

# A directory in PATH whose gtar drops the first line of every listing, i.e.
# of every call whose option cluster starts with -t.
stub_gtar_dropping_a_listing_line() {
  local real stub="$BATS_TEST_TMPDIR/stub"
  real="$(command -v gtar)"
  mkdir -p "$stub"
  cat > "$stub/gtar" <<EOF
#!/usr/bin/env bash
for arg in "\$@"; do
  case "\$arg" in
    -t*) "$real" "\$@" | sed 1d; exit "\${PIPESTATUS[0]}" ;;
  esac
done
exec "$real" "\$@"
EOF
  chmod +x "$stub/gtar"
  PATH="$stub:$PATH"
}
