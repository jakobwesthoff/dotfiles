# shellcheck shell=bash
# description: Limit sshd to key authentication

# sshd uses the first value it reads for a setting, and the include of
# sshd_config.d/*.conf comes first in Fedora's sshd_config, so the
# lowest-numbered drop-in wins over Fedora's own 50-redhat.conf.
sshd_dropin=/etc/ssh/sshd_config.d/10-keys-only.conf
if sudo test -f "${sshd_dropin}"; then
	skip "sshd already limited to keys"
else
	sudo tee "${sshd_dropin}" >/dev/null <<'SSHD'
PasswordAuthentication no
KbdInteractiveAuthentication no
SSHD
	sudo sshd -t
	sudo systemctl reload sshd
	ok "sshd accepts keys only"
fi
