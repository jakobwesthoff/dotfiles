# Lets `cd <part of a name><TAB>` find folders whose names only contain
# what was typed, such as the date-prefixed folders in ~/playground,
# while a folder that starts with the typed text always wins.
#
# zsh's `_main_complete` tries each `matcher-list` entry in turn, stops at
# the first that yields matches, and hands the current one to
# `_description` as `$_matcher`, which becomes `compadd -M`. The style
# cannot be limited to `cd`, as it is looked up before the command is
# known, so this wrapper runs the same loop around `_cd` alone and every
# other command keeps plain prefix matching.
#
# The matchers, strictest first:
#   ''                     prefix, as zsh does by default
#   m:{a-zA-Z}={A-Za-z}    prefix, ignoring case
#   ... l:|=* r:|=*        substring anywhere in the name
#   ... r:|?=**            subsequence, so `dsplnk` finds `displaylink`
#
# A prefix match hides all looser matches: with `Research-old` and
# `2026_11_12_research` side by side, `cd rese<TAB>` only offers the first.
_cd_prefer_prefix() {
  local _matcher
  for _matcher in \
    '' \
    'm:{a-zA-Z}={A-Za-z}' \
    'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*' \
    'm:{a-zA-Z}={A-Za-z} r:|?=**'
  do
    _cd "$@" && return 0
  done
  return 1
}
compdef _cd_prefer_prefix cd
