# shellcheck shell=bash
# description: Install security updates automatically (dnf-automatic)

automatic_conf=/etc/dnf/automatic.conf
if sudo grep -q '^upgrade_type = security$' "${automatic_conf}" 2>/dev/null; then
	skip "dnf-automatic already configured"
else
	sudo dnf install -y dnf5-plugin-automatic
	sudo tee "${automatic_conf}" >/dev/null <<'AUTOMATIC'
[commands]
upgrade_type = security
apply_updates = yes
reboot = never
AUTOMATIC
	ok "dnf-automatic installs security updates, without rebooting"
fi
sudo systemctl enable --now dnf5-automatic.timer
ok "dnf5-automatic.timer enabled"
