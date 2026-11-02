#!/usr/bin/env bats

# shellcheck disable=SC2030,SC2031 # bats runs each test in a subshell of its own, so exports stay local to it on purpose

bats_require_minimum_version 1.5.0
load timecapsule-helpers

setup() {
  setup_sync
}

teardown() {
  restore_config_permissions
}

# =========================================================
# Missing or unusable config file
# =========================================================

@test "a missing config file stops the run and names the file and every key" {
  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG"* ]]
  [[ "$output" == *"not found or not readable"* ]]
  for key in NAS_HOST NAS_USER REMOTE_BASE HOME_GATEWAY HOME_SUBNET_PREFIX; do
    [[ "$output" == *"$key"* ]]
  done
  assert_no_commands_ran
}

@test "a config path that is a directory stops the run" {
  mkdir "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"not found or not readable"* ]]
  assert_no_commands_ran
}

@test "a config file without read permission stops the run" {
  [ "$(id -u)" -ne 0 ] || skip "root reads files whatever their mode"
  write_config
  chmod 000 "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"not found or not readable"* ]]
  assert_no_commands_ran
}

# =========================================================
# Missing keys
# =========================================================

@test "every missing key is named in one message" {
  printf '%s\n' "NAS_HOST=$PLACEHOLDER_HOST" "NAS_USER=$PLACEHOLDER_USER" > "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG is missing: REMOTE_BASE, HOME_GATEWAY, HOME_SUBNET_PREFIX"* ]]
  [[ "$output" != *"NAS_HOST"* ]]
  [[ "$output" != *"NAS_USER"* ]]
  assert_no_commands_ran
}

@test "a key with an empty value counts as missing" {
  write_config
  gsed -i 's/^NAS_USER=.*/NAS_USER=/' "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG is missing: NAS_USER"* ]]
  assert_no_commands_ran
}

@test "an environment variable does not stand in for a missing key" {
  export NAS_HOST=from-the-environment.example
  write_config
  gsed -i '/^NAS_HOST=/d' "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG is missing: NAS_HOST"* ]]
  assert_no_commands_ran
}

# =========================================================
# Syntax
# =========================================================

@test "an unknown key is named with its line" {
  printf '%s\n' "NAS_HOST=$PLACEHOLDER_HOST" "NAS_USER=$PLACEHOLDER_USER" "NAS_HOTS=typo" > "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG:3: unknown key \"NAS_HOTS\""* ]]
  assert_no_commands_ran
}

@test "two known keys joined by a space are not a known key" {
  printf '%s\n' "NAS_HOST NAS_USER=x" > "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG:1: unknown key \"NAS_HOST NAS_USER\""* ]]
  assert_no_commands_ran
}

@test "a line without an equals sign is reported with its line" {
  printf '%s\n' "NAS_HOST=$PLACEHOLDER_HOST" "just some words" > "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG:2: expected KEY=VALUE"* ]]
  assert_no_commands_ran
}

@test "a HOME_SUBNET_PREFIX without a trailing dot is refused" {
  write_config
  gsed -i 's/^HOME_SUBNET_PREFIX=.*/HOME_SUBNET_PREFIX=192.168.1/' "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$CONFIG:5: HOME_SUBNET_PREFIX must end in a dot"* ]]
  assert_no_commands_ran
}

# =========================================================
# What the format allows
# =========================================================

@test "comments, blank lines and spaces around keys and values are ignored" {
  {
    printf '# the NAS\n\n   # indented comment\n'
    printf '  NAS_HOST  =  other.example  \n'
    printf '%s\n' "NAS_USER=$PLACEHOLDER_USER" "REMOTE_BASE=$PLACEHOLDER_BASE" \
      "HOME_GATEWAY=$PLACEHOLDER_GATEWAY" "HOME_SUBNET_PREFIX=$PLACEHOLDER_PREFIX"
  } > "$CONFIG"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check other.example
}

@test "a config with CRLF line endings is read" {
  write_config
  gsed -i 's/$/\r/' "$CONFIG"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
}

@test "a config that starts with a byte order mark is read" {
  { printf '\xef\xbb\xbf# the NAS\n'; write_config /dev/stdout; } > "$CONFIG"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
}

@test "a last line without a newline is read" {
  printf '%s' "$(write_config /dev/stdout)" > "$CONFIG"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
}

@test "a value may contain equals signs, spaces and hash signs" {
  write_config
  gsed -i 's|^REMOTE_BASE=.*|REMOTE_BASE=/mnt/pool/a b=c #d|' "$CONFIG"
  export STUB_SSH_RC=1

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"/mnt/pool/a b=c #d not found on $PLACEHOLDER_HOST"* ]]
}

@test "a key given twice takes its later value" {
  { printf 'NAS_HOST=first.example\n'; write_config /dev/stdout; } > "$CONFIG"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
  [[ "$output" != *"first.example"* ]]
}

# =========================================================
# The config is data, not code
# =========================================================

@test "a command substitution in a value is kept as text and not run" {
  local marker="$BATS_TEST_TMPDIR/marker"
  write_config
  # shellcheck disable=SC2016 # the $( ) must reach the file unexpanded
  printf 'NAS_HOST=$(touch %s)\n' "$marker" >> "$CONFIG"
  export STUB_NC_RC=1

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [ ! -e "$marker" ]
  # shellcheck disable=SC2016 # the $( ) is the literal text expected
  [[ "$output" == *'$(touch '*") ($PLACEHOLDER_IP) does not answer on port 22"* ]]
}

@test "a command on a line of its own is a syntax error and not run" {
  local marker="$BATS_TEST_TMPDIR/marker"
  printf 'touch %s\n' "$marker" > "$CONFIG"

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [ ! -e "$marker" ]
  [[ "$output" == *"$CONFIG:1: expected KEY=VALUE"* ]]
}

# =========================================================
# Every key reaches the step that uses it
# =========================================================

@test "a valid config runs on to the port check and calls no ssh" {
  write_config
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
  [ "$(cat "$CALLS")" = "rsync --info=help
scutil --get ComputerName
dscacheutil -q host -a name $PLACEHOLDER_HOST
nc -z -G 2 $PLACEHOLDER_IP 22" ]
}

@test "NAS_USER and NAS_HOST name the ssh login" {
  write_config
  export STUB_SSH_RC=255

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"ssh to $PLACEHOLDER_USER@$PLACEHOLDER_HOST failed"* ]]
}

@test "REMOTE_BASE names the directory looked for on the NAS" {
  write_config
  export STUB_SSH_RC=1

  run_sync --skip-network-check
  [ "$status" -eq 1 ]

  [[ "$output" == *"$PLACEHOLDER_BASE not found on $PLACEHOLDER_HOST"* ]]
}

@test "HOME_GATEWAY is the gateway the home network is recognised by" {
  write_config
  export STUB_GATEWAY=10.0.0.1

  run_sync
  [ "$status" -eq 1 ]

  [[ "$output" == *"default gateway 10.0.0.1, expected $PLACEHOLDER_GATEWAY"* ]]
}

@test "HOME_SUBNET_PREFIX is the prefix the NAS address must carry" {
  write_config
  export STUB_IP=10.9.9.9

  run_sync
  [ "$status" -eq 1 ]

  [[ "$output" == *"outside the home network ${PLACEHOLDER_PREFIX}0/24"* ]]
}

@test "--host replaces the address but not the host key alias" {
  export NAS_HOST=wrong.example
  write_config

  run_sync --skip-network-check --host 192.0.2.7
  [ "$status" -eq 0 ]

  ssh_call="$(grep '^ssh ' "$CALLS" | head -n 1)"
  [[ "$ssh_call" == *"HostKeyAlias=$PLACEHOLDER_HOST"* ]]
  [[ "$ssh_call" == *"$PLACEHOLDER_USER@192.0.2.7"* ]]
}

# =========================================================
# Where the config lives
# =========================================================

@test "TIMECAPSULE_SYNC_CONFIG wins over the default locations" {
  write_config
  mkdir -p "$HOME/.config/playground"
  write_config "$HOME/.config/playground/timecapsule-sync"
  gsed -i 's/^NAS_HOST=.*/NAS_HOST=home.example/' "$HOME/.config/playground/timecapsule-sync"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
}

@test "XDG_CONFIG_HOME holds the config when no override is given" {
  unset TIMECAPSULE_SYNC_CONFIG
  export XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/xdg"
  mkdir -p "$XDG_CONFIG_HOME/playground"
  write_config "$XDG_CONFIG_HOME/playground/timecapsule-sync"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
}

@test ".config in the home directory holds the config without XDG_CONFIG_HOME" {
  unset TIMECAPSULE_SYNC_CONFIG
  mkdir -p "$HOME/.config/playground"
  write_config "$HOME/.config/playground/timecapsule-sync"
  export STUB_NC_RC=1

  run_sync --skip-network-check

  assert_reached_port_check "$PLACEHOLDER_HOST"
}

@test "--help needs no config" {
  run_sync --help
  [ "$status" -eq 0 ]

  [[ "$output" == "usage:"* ]]
  assert_no_commands_ran
}

# =========================================================
# The transfer itself
# =========================================================

# A run with stdout redirected, as from cron or launchd, leaves the progress
# option array empty, and the transfer has to complete all the same.
@test "a transfer with stdout redirected completes" {
  write_config

  run_full_sync --skip-network-check

  [ "$status" -eq 0 ]
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" == *"synced         $PLACEHOLDER_USER@$PLACEHOLDER_HOST:$PLACEHOLDER_BASE/testbox" ]]
  [ "$(tail -n 1 "$CALLS")" = "$(expected_transfer_call)" ]
}

@test "a transfer on a terminal asks rsync for progress" {
  command -v script >/dev/null || skip "script gives the run a terminal"
  write_config

  SYNC_TTY=1 run_full_sync --skip-network-check

  [ "$status" -eq 0 ]
  [ -s "$CALLS" ]
  [ "$(tail -n 1 "$CALLS")" = "$(expected_transfer_call ' --info=progress2')" ]
}

# =========================================================
# The bash version the script needs
# =========================================================

@test "--help under an older bash stops with a message and prints no usage" {
  skip_unless_system_bash_is_old

  run_script_under_system_bash --help
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"ERROR: timecapsule-sync.sh needs bash 4.4 or newer, but runs under bash $(system_bash_version) ($SYSTEM_BASH)"* ]]
  assert_no_commands_ran
}

@test "a sync run under an older bash stops before any command" {
  skip_unless_system_bash_is_old
  write_config

  run_script_under_system_bash --skip-network-check
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"needs bash 4.4 or newer"* ]]
  assert_no_commands_ran
}

@test "the version test refuses bash before 4.4 and accepts 4.4 and newer" {
  assert_version_test_draws_the_line_at_4_4 "$ROOT/timecapsule-sync.sh"
}
