# shellcheck shell=bash
# Presetup for Fedora, sourced by setup.sh from setup/fedora/. Fedora
# ships a current bash already; this adds what setup.sh needs before it
# can show the checklist: dialog, plus git and stow for linking.

if ! grep -q '^ID=fedora$' /etc/os-release 2>/dev/null; then
	fail "The fedora layer runs on Fedora only"
	exit 1
fi
ok "Running on $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"

info "Installing dialog, git and stow..."
sudo dnf install -y dialog git stow
ok "dialog, git and stow ready"
