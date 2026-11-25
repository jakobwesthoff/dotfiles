# shellcheck shell=bash
# description: Require the password 5 seconds after the screen saver or display sleep

# `sysadminctl -screenLock status` needs no password and prints, on its
# log line, e.g. "screenLock delay is 5 seconds" (macOS 27).
current=$(sysadminctl -screenLock status 2>&1 </dev/null || true)
if echo "${current}" | grep -q "screenLock delay is 5 seconds"; then
	skip "Lock screen already requires the password after 5 seconds"
else
	# `-password -` makes sysadminctl prompt for the login password
	# instead of taking it on the command line.
	sysadminctl -screenLock 5 -password -
	current=$(sysadminctl -screenLock status 2>&1 </dev/null || true)
	if echo "${current}" | grep -q "screenLock delay is 5 seconds"; then
		ok "Lock screen requires the password after 5 seconds"
	else
		warn "sysadminctl did not confirm the setting: ${current##*] }"
		info "Set it by hand: Settings -> Lock Screen -> Require password after screen saver begins or display is turned off"
	fi
fi
