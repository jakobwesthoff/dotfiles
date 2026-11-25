# shellcheck shell=bash
# description: Turn FileVault on (shows the recovery key once)

if fdesetup status | grep -q "FileVault is On"; then
	ok "FileVault is enabled"
else
	# fdesetup asks for the login password and prints the personal
	# recovery key; nothing stores the key for you.
	info "Enabling FileVault..."
	sudo fdesetup enable -user "$USER"
	ask "Store the recovery key above somewhere safe (e.g. 1Password), then press ENTER"
	read -r
	ok "FileVault enabled"
fi
