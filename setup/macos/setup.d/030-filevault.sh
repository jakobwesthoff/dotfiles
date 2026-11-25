# shellcheck shell=bash
# description: Check that FileVault is on

if fdesetup status | grep -q "FileVault is On"; then
	ok "FileVault is enabled"
else
	warn "FileVault is NOT enabled"
	ask "Enable it: Settings -> Privacy & Security -> FileVault -> Turn On"
	echo "     Press ENTER when done"
	read -r
fi
