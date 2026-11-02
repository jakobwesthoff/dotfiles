# shellcheck shell=bash
#
# What the tests of the bash version check share. macOS ships /bin/bash as
# 3.2, older than both scripts accept, so a run through it shows the refusal.

SYSTEM_BASH=/bin/bash

# The refusal can only be shown by a bash older than 4.4.
skip_unless_system_bash_is_old() {
  [ -x "$SYSTEM_BASH" ] || skip "$SYSTEM_BASH is not installed"
  # shellcheck disable=SC2016 # the snippet is expanded by the system bash
  "$SYSTEM_BASH" -c '[ "${BASH_VERSINFO[0]}" -lt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -lt 4 ]; }' \
    || skip "$SYSTEM_BASH is bash 4.4 or newer"
}

# The version of the bash the refusal names.
system_bash_version() {
  # shellcheck disable=SC2016 # expanded by the system bash
  "$SYSTEM_BASH" -c 'printf %s "$BASH_VERSION"'
}

# Checks the version test of a script against version numbers no installed bash
# has to provide: the function is cut out of the script and run here.
assert_version_test_draws_the_line_at_4_4() {
  local script="$1" definition pair
  definition="$(gsed -n '/^bash_is_too_old() {/,/^}/p' "$script")"
  [ -n "$definition" ]
  eval "$definition"
  for pair in "3 2" "3 9" "4 0" "4 3"; do
    # shellcheck disable=SC2086 # a pair is major and minor, two words
    bash_is_too_old $pair || return 1
  done
  for pair in "4 4" "4 10" "5 0" "5 3"; do
    # shellcheck disable=SC2086 # a pair is major and minor, two words
    if bash_is_too_old $pair; then
      return 1
    fi
  done
}
