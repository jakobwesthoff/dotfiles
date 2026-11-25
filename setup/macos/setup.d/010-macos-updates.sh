# shellcheck shell=bash
# description: Install pending macOS updates (restart afterwards if needed)

info "Checking for macOS updates..."
update_output="$(softwareupdate -l 2>&1)"
if echo "${update_output}" | grep -q "No new software available"; then
	ok "macOS is up to date"
else
	echo "${update_output}" | grep '^\* Label:' | sed 's/^\* Label: /    /' | while read -r line; do
		info "${line}"
	done
	# Without -R: an update that needs a restart would otherwise restart
	# the Mac in the middle of the setup.
	info "Installing updates (this may take a while)..."
	sudo softwareupdate -i -a --agree-to-license
	if echo "${update_output}" | grep -q "Action: restart"; then
		warn "An update needs a restart. Restart once the setup is done."
	fi
	ok "Updates installed"
fi
