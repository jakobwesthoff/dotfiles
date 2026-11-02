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
  # Where archives that the script did not write are built from.
  FOREIGN="$BATS_TEST_TMPDIR/foreign"
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
  find "$1" -exec touch -h -t "$(stamp_days_ago "$2")" {} +
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

# Like run_archive, but stdout lands in $output and stderr in $stderr. Needs
# bats_require_minimum_version 1.5.0 in the test file.
run_archive_split() {
  local trace=()
  if [ -n "${ARCHIVE_TRACE:-}" ]; then
    # shellcheck disable=SC2016 # PS4 is expanded by the traced shell
    trace=(SHELLOPTS=xtrace PS4='+${BASH_SOURCE}:${LINENO}: ' BASH_XTRACEFD=9)
  fi
  # shellcheck disable=SC2154 # run sets status, output and stderr
  run --separate-stderr env ${trace[@]+"${trace[@]}"} \
    "${ARCHIVE_BASH:-bash}" "$ROOT/archive.sh" "$@" 9>>"${ARCHIVE_TRACE:-/dev/null}"
}

# Starts a command in a session of its own. A session has no controlling
# terminal, so opening /dev/tty fails and the script finds nobody to ask. The
# device node stays a character device, which is why can_prompt has to try to
# open it. macOS has no setsid(1). setsid(2) fails for a process group leader,
# and the die turns that into a visible error instead of a run that still has
# a terminal.
NO_TERMINAL=(perl -MPOSIX -e 'POSIX::setsid() != -1 or die "setsid: $!\n"; exec @ARGV')

# Runs the script like run_archive, without a controlling terminal.
run_without_terminal() {
  local trace=()
  if [ -n "${ARCHIVE_TRACE:-}" ]; then
    # shellcheck disable=SC2016 # PS4 is expanded by the traced shell
    trace=(SHELLOPTS=xtrace PS4='+${BASH_SOURCE}:${LINENO}: ' BASH_XTRACEFD=9)
  fi
  run "${NO_TERMINAL[@]}" env ${trace[@]+"${trace[@]}"} \
    "${ARCHIVE_BASH:-bash}" "$ROOT/archive.sh" "$@" 9>>"${ARCHIVE_TRACE:-/dev/null}"
}

# Limits PATH to the tools the script and the helpers need, minus the named
# one, followed by the system directories. gtar, gsed, xz and fzf live next
# to bash in Homebrew's directory, so removing that directory from PATH
# would remove all of them at once. Skips the test where the system
# directories provide the tool themselves.
path_without() {
  local omit="$1" dir="$BATS_TEST_TMPDIR/path-without-$1" tool real
  if PATH=/usr/bin:/bin command -v "$omit" > /dev/null; then
    skip "$omit is in the system directories"
  fi
  mkdir -p "$dir"
  for tool in bash gtar gsed xz expect fzf; do
    [ "$tool" != "$omit" ] || continue
    real="$(command -v "$tool")" || continue
    ln -s "$real" "$dir/$tool"
  done
  PATH="$dir:/usr/bin:/bin"
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
  local trace=()
  if [ -n "${ARCHIVE_TRACE:-}" ]; then
    # shellcheck disable=SC2016 # PS4 is expanded by the traced shell
    trace=(SHELLOPTS=xtrace PS4='+${BASH_SOURCE}:${LINENO}: ' BASH_XTRACEFD=9)
  fi
  run bash -c '
    answers="$1"; exp="$2"; shift 2
    ANSWERS="$answers" expect "$exp" "$@" | tr -d "\r" | gsed "s/\x1b\[[0-9;]*m//g"
    exit "${PIPESTATUS[0]}"
  ' _ "$answers" "$ANSWER_EXP" env ${trace[@]+"${trace[@]}"} \
    "${ARCHIVE_BASH:-bash}" "$ROOT/archive.sh" "$@" 9>>"${ARCHIVE_TRACE:-/dev/null}"
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

# A directory in PATH whose mv fails for any listing part file and passes
# everything else on, i.e. a listing that cannot be put in place.
stub_mv_failing_on_listing_parts() {
  local real stub="$BATS_TEST_TMPDIR/stub-mv"
  real="$(command -v mv)"
  mkdir -p "$stub"
  cat > "$stub/mv" <<EOS
#!/usr/bin/env bash
for arg in "\$@"; do
  case "\$arg" in
    *.lst.part) exit 1 ;;
  esac
done
exec "$real" "\$@"
EOS
  chmod +x "$stub/mv"
  PATH="$stub:$PATH"
}

# The listing the script is specified to write for an archive, produced
# independently of the script's own code.
listing_oracle() {
  LC_ALL=C TZ=UTC gtar --quoting-style=literal -tvf "$1"
}

# Directories left unwritable by a test would block bats' cleanup.
restore_permissions() {
  chmod -R u+rwx "$BATS_TEST_TMPDIR" 2>/dev/null || true
}

# An archive as another tool or an earlier version of the script would have
# left it: a plain tarball of a generated directory, without a listing.
make_unlisted_archive() {
  local name="$1"
  make_dir "$name" 30
  gtar --sort=name -cf - -C "$ROOT" "$name" | xz -c > "$ARCHIVE/$name.tar.xz"
  rm -rf "${ROOT:?}/$name"
}

# A directory in PATH whose fzf stands in for the picker. It records its
# arguments and what it was fed, drains all of stdin so that the script's
# pipeline sees no broken pipe, and prints the line given as the argument.
# Without an argument it prints nothing and exits 130, fzf's status for a
# cancelled pick. The variables are exported because the script runs below
# bash -c and expect.
stub_fzf() {
  local stub="$BATS_TEST_TMPDIR/stub-fzf"
  FZF_ARGS_FILE="$BATS_TEST_TMPDIR/fzf-args"
  FZF_INPUT_FILE="$BATS_TEST_TMPDIR/fzf-input"
  FZF_PICK="${1:-}"
  FZF_EXIT=130
  export FZF_ARGS_FILE FZF_INPUT_FILE FZF_PICK FZF_EXIT
  mkdir -p "$stub"
  cat > "$stub/fzf" <<'EOS'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$FZF_ARGS_FILE"
cat > "$FZF_INPUT_FILE"
if [ -n "$FZF_PICK" ]; then
  grep -Fx -- "$FZF_PICK" "$FZF_INPUT_FILE"
  exit
fi
exit "$FZF_EXIT"
EOS
  chmod +x "$stub/fzf"
  PATH="$stub:$PATH"
}

# The argument fzf received after the given option, one per line in
# $FZF_ARGS_FILE.
fzf_option_value() {
  grep -x -A1 -- "$1" "$FZF_ARGS_FILE" | tail -n 1
}

# Files under $FOREIGN, aged like make_dir's, for archives that the script
# did not write. Paths are relative to $FOREIGN.
make_foreign_tree() {
  local file
  for file in "$@"; do
    mkdir -p "$FOREIGN/$(dirname "$file")"
    printf '%s\n' "$file" > "$FOREIGN/$file"
  done
  touch_tree "$FOREIGN" 30
}

# archive/<name>.tar.xz holding the given members of $FOREIGN.
foreign_archive() {
  local name="$1"
  shift
  gtar --sort=name -cf - -C "$FOREIGN" "$@" | xz -c > "$ARCHIVE/$name.tar.xz"
}

# A directory in PATH whose gtar fails when it extracts, i.e. when one of its
# arguments is -xJf as in cmd_retrieve. Listing and comparing pass through.
stub_gtar_failing_on_extract() {
  local real stub="$BATS_TEST_TMPDIR/stub-gtar-extract"
  real="$(command -v gtar)"
  mkdir -p "$stub"
  cat > "$stub/gtar" <<EOS
#!/usr/bin/env bash
for arg in "\$@"; do
  [ "\$arg" != -xJf ] || exit 2
done
exec "$real" "\$@"
EOS
  chmod +x "$stub/gtar"
  PATH="$stub:$PATH"
}

# A directory in PATH whose gtar creates the directory given as $1 once it
# has extracted, i.e. a name that appears in the playground during a retrieve.
stub_gtar_creating_dir_after_extract() {
  local real stub="$BATS_TEST_TMPDIR/stub-gtar-appear"
  real="$(command -v gtar)"
  mkdir -p "$stub"
  cat > "$stub/gtar" <<EOS
#!/usr/bin/env bash
"$real" "\$@" || exit
for arg in "\$@"; do
  [ "\$arg" != -xJf ] || mkdir "$1"
done
EOS
  chmod +x "$stub/gtar"
  PATH="$stub:$PATH"
}

# A directory in PATH whose xz fails when it compresses, i.e. when one of its
# arguments is -9 as in XZ_OPTS. Testing and decompressing pass through.
stub_xz_failing_on_compress() {
  local real stub="$BATS_TEST_TMPDIR/stub-xz"
  real="$(command -v xz)"
  mkdir -p "$stub"
  cat > "$stub/xz" <<EOS
#!/usr/bin/env bash
for arg in "\$@"; do
  [ "\$arg" != -9 ] || exit 1
done
exec "$real" "\$@"
EOS
  chmod +x "$stub/xz"
  PATH="$stub:$PATH"
}

# A flat directory of the named files at <dir>, aged like make_dir's. Each file
# holds its own name, so two directories built from the same names are
# identical.
make_files() {
  local dir="$1" file
  shift
  mkdir -p "$dir"
  for file in "$@"; do
    printf '%s\n' "$file" > "$dir/$file"
  done
  touch_tree "$dir" 30
}

# archive/<name>.tar.xz of a flat directory <name> holding the named files,
# without a provenance record. A directory made with make_files in $ROOT
# overlaps it by exactly the names the two share.
make_archive_of() {
  local name="$1"
  shift
  make_files "$FOREIGN/$name" "$@"
  foreign_archive "$name" "$name"
}

# old.tar.xz plus a second archive of old kept beside it, which holds new.txt.
# Leaves no old directory in $ROOT and the beside archive's path in $BESIDE.
# shellcheck disable=SC2119,SC2154,SC2034 # status is set by bats' run, BESIDE is read by the tests
make_two_archives_of_old() {
  collide_with_changed_copy
  run_with_answers "s -"
  [ "$status" -eq 0 ]
  local found=("$ARCHIVE"/old.????-??-??.tar.xz)
  BESIDE="${found[0]}"
}

# A directory in PATH whose xz counts what it decompresses. Every call with an
# argument that starts with -d, i.e. the script's `xz -dc` and the `xz -d` that
# gtar starts for -J, runs the real xz through a filter that passes the data on,
# stops when its reader leaves and appends the number of bytes it saw to
# $XZ_BYTES_FILE before the stub exits, so the count is in place when `run`
# returns. Other calls pass through. Install it after the fixture is built.
stub_xz_counting_decompressed_bytes() {
  local real stub="$BATS_TEST_TMPDIR/stub-xz-count"
  real="$(command -v xz)"
  XZ_BYTES_FILE="$BATS_TEST_TMPDIR/xz-bytes"
  export XZ_BYTES_FILE
  rm -f "$XZ_BYTES_FILE"
  mkdir -p "$stub"
  cat > "$stub/xz" <<EOS
#!/usr/bin/env bash
for arg in "\$@"; do
  case "\$arg" in
    -d*)
      "$real" "\$@" | perl -e '
        \$SIG{PIPE} = "IGNORE";
        my (\$n, \$buf) = (0, "");
        while (my \$got = read(STDIN, \$buf, 65536)) {
          \$n += \$got;
          print STDOUT \$buf or last;
        }
        open(my \$out, ">>", \$ENV{XZ_BYTES_FILE}) or die "\$!";
        print \$out "\$n\n";
        close(\$out);
      '
      exit "\${PIPESTATUS[0]}"
      ;;
  esac
done
exec "$real" "\$@"
EOS
  chmod +x "$stub/xz"
  PATH="$stub:$PATH"
}

# What the counting xz saw in total, 0 when it was never asked to decompress.
xz_bytes_read() {
  if [ -e "$XZ_BYTES_FILE" ]; then
    awk '{ total += $1 } END { print total + 0 }' "$XZ_BYTES_FILE"
  else
    printf '0\n'
  fi
}

# archive/big.tar.xz holding the hidden directory .big, which is one file of
# incompressible data of <mib> MiB. Retrieving it dies at once, because a hidden
# directory cannot be restored, so a test sees what naming the directory reads
# and nothing else. The archive is named without the dot because archive names
# beginning with one are not listed.
make_big_hidden_archive() {
  local mib="$1"
  rm -rf "${FOREIGN:?}/.big"
  mkdir -p "$FOREIGN/.big"
  head -c $((mib * 1048576)) /dev/urandom > "$FOREIGN/.big/data"
  foreign_archive big .big
}

# archive/<name>.tar.xz holding the hidden directory <member> as a pax stream
# whose first header carries a record of 1.2 MB, longer than anything the
# script's own archives start with. $FOREIGN/<member> must exist. The record is
# an extended header for the next entry, built by hand because tar offers no
# way to write one that large.
foreign_archive_with_huge_first_header() {
  local name="$1" member="$2"
  {
    perl -e '
      my $body = " comment=" . ("x" x 1200000) . "\n";
      my ($len, $digits);
      for $digits (1 .. 10) {
        $len = length($body) + $digits;
        last if length($len) == $digits;
      }
      my $data = "$len$body";
      my $head = pack("a100 a8 a8 a8 a12 a12 a8 a1 a100 a6 a2 a32 a32 a8 a8 a155 x12",
        "PaxHeader/x", "0000644", "0000000", "0000000",
        sprintf("%011o", length($data)), "00000000000", "        ", "x",
        "", "ustar", "00", "", "", "", "", "");
      my $sum = 0;
      $sum += ord($_) for split //, $head;
      substr($head, 148, 8) = sprintf("%06o", $sum) . "\0 ";
      print $head, $data, "\0" x ((512 - length($data) % 512) % 512);
    '
    gtar --format=pax --sort=name -cf - -C "$FOREIGN" "$member"
  } | xz -c > "$ARCHIVE/$name.tar.xz"
}
