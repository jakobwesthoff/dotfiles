# shellcheck shell=bash
# description: Enable Touch ID for sudo

if [ -f /etc/pam.d/sudo_local ]; then
	skip "Touch ID for sudo already configured"
else
	info "Enabling Touch ID for sudo..."
	sudo tee /etc/pam.d/sudo_local >/dev/null <<'PAM'
auth       sufficient     pam_tid.so
PAM
	ok "Touch ID for sudo enabled"
fi
