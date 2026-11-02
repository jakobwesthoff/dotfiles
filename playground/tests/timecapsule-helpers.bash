# shellcheck shell=bash
#
# Shared fixtures for the timecapsule-sync.sh tests.
#
# The script derives ROOT from its own location, so every test gets a copy of
# it next to an archive/ directory in BATS_TEST_TMPDIR. Every external command
# the script reaches before it syncs is replaced by a stub on PATH, so no test
# can touch a network, a real host or the real ~/.config.

# The placeholder site the stubs answer for. Tests that change what a stub
# says export the matching STUB_* variable first.
PLACEHOLDER_HOST=nas.local
PLACEHOLDER_USER=someone
PLACEHOLDER_BASE=/mnt/pool/timecapsule/playground
PLACEHOLDER_GATEWAY=192.168.1.1
PLACEHOLDER_PREFIX=192.168.1.
PLACEHOLDER_IP=192.168.1.20

STUBBED_COMMANDS="rsync scutil route dscacheutil nc ssh"

setup_sync() {
  ROOT="$BATS_TEST_TMPDIR/root"
  mkdir -p "$ROOT/archive"
  cp "$BATS_TEST_DIRNAME/../timecapsule-sync.sh" "$ROOT/timecapsule-sync.sh"

  # A HOME of its own keeps the default config location away from the
  # developer's real one.
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  unset XDG_CONFIG_HOME NAS_HOST NAS_USER REMOTE_BASE HOME_GATEWAY HOME_SUBNET_PREFIX
  CONFIG="$BATS_TEST_TMPDIR/config"
  export TIMECAPSULE_SYNC_CONFIG="$CONFIG"

  CALLS="$BATS_TEST_TMPDIR/calls"
  export CALLS
  export STUB_GATEWAY="$PLACEHOLDER_GATEWAY" STUB_IP="$PLACEHOLDER_IP"
  export STUB_NC_RC=0 STUB_SSH_RC=0
  write_stubs
}

# Every stub logs "<name> <arguments>" to CALLS, so a test can tell which
# commands ran and with what.
# The stub text is written literally and expanded when the stub runs.
# shellcheck disable=SC2016
write_stubs() {
  local stub="$BATS_TEST_TMPDIR/stub" name
  mkdir -p "$stub"

  for name in $STUBBED_COMMANDS; do
    printf '#!/usr/bin/env bash\nprintf "%%s\\n" "%s $*" >> "$CALLS"\n' "$name" > "$stub/$name"
  done
  printf 'printf "testbox\\n"\n' >> "$stub/scutil"
  printf 'printf "gateway: %%s\\n" "$STUB_GATEWAY"\n' >> "$stub/route"
  printf 'printf "ip_address: %%s\\n" "$STUB_IP"\n' >> "$stub/dscacheutil"
  printf 'exit "$STUB_NC_RC"\n' >> "$stub/nc"
  printf 'exit "$STUB_SSH_RC"\n' >> "$stub/ssh"
  chmod +x "$stub"/*

  PATH="$stub:$PATH"

  # A stub that PATH does not find first would let the script reach the
  # real command.
  for name in $STUBBED_COMMANDS; do
    if [ "$(command -v "$name")" != "$stub/$name" ]; then
      printf 'stub for %s is not first on PATH\n' "$name" >&2
      return 1
    fi
  done
}

# A complete config for the placeholder site, one key per line in the order
# of the script's documentation.
write_config() {
  printf '%s\n' \
    "NAS_HOST=$PLACEHOLDER_HOST" \
    "NAS_USER=$PLACEHOLDER_USER" \
    "REMOTE_BASE=$PLACEHOLDER_BASE" \
    "HOME_GATEWAY=$PLACEHOLDER_GATEWAY" \
    "HOME_SUBNET_PREFIX=$PLACEHOLDER_PREFIX" > "${1:-$CONFIG}"
}

# Runs the script under test. Always a dry run: the real transfer is not
# something these tests exercise.
#
# With SYNC_TRACE set, every executed line is appended to that file as
# "+<script>:<line>: <command>". The trace goes to fd 9 so that it does not
# mix into the output the tests assert on. SYNC_BASH picks the interpreter;
# bash 3.2 ignores BASH_XTRACEFD and would put the trace into the output, so
# the combination is refused.
run_sync() {
  if [ -n "${SYNC_TRACE:-}" ]; then
    if [ "${SYNC_BASH:-bash}" = /bin/bash ]; then
      printf 'SYNC_TRACE needs a bash that honours BASH_XTRACEFD\n' >&2
      return 1
    fi
    # shellcheck disable=SC2016 # PS4 is expanded by the traced shell
    run env SHELLOPTS=xtrace PS4='+${BASH_SOURCE}:${LINENO}: ' BASH_XTRACEFD=9 \
      "${SYNC_BASH:-bash}" "$ROOT/timecapsule-sync.sh" --dry-run "$@" 9>>"$SYNC_TRACE"
  else
    run "${SYNC_BASH:-bash}" "$ROOT/timecapsule-sync.sh" --dry-run "$@"
  fi
}

# Directories left unreadable by a test would block bats' cleanup.
restore_config_permissions() {
  chmod -R u+rwx "$BATS_TEST_TMPDIR" 2>/dev/null || true
}

# A run that got past the config and stopped at the port check, which names
# the host the config gave.
# shellcheck disable=SC2154 # status and output are set by bats' run
assert_reached_port_check() {
  [ "$status" -eq 1 ]
  [[ "$output" == *"$1 ($PLACEHOLDER_IP) does not answer on port 22"* ]]
}

assert_no_commands_ran() {
  [ ! -s "$CALLS" ]
}
