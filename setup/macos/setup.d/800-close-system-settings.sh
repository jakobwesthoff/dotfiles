# shellcheck shell=bash
# description: Close System Settings so it does not overwrite the defaults

osascript -e 'tell application "System Settings" to quit'
info "Closed System Settings to prevent conflicts"
