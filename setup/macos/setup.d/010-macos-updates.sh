# shellcheck shell=bash
# description: Check for macOS updates

info "Checking for macOS updates..."
update_output="$(softwareupdate -l 2>&1)"
if echo "${update_output}" | grep -q "No new software available"; then
	ok "macOS is up to date"
else
	warn "Available updates:"
	echo "${update_output}" | grep '^\* Label:' | sed 's/^\* Label: /    /' | while read -r line; do
		info "${line}"
	done
	ask "Install updates via: Apple Menu -> About This Mac -> Software Update"
	echo "     Press ENTER to continue (or install later)"
	read -r
fi
