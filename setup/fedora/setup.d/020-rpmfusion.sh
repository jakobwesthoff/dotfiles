# shellcheck shell=bash
# description: Enable the RPM Fusion repositories (free and nonfree)

if rpm -q rpmfusion-free-release rpmfusion-nonfree-release &>/dev/null; then
	skip "RPM Fusion already enabled"
else
	info "Enabling RPM Fusion free and nonfree..."
	fedora_version=$(rpm -E %fedora)
	sudo dnf install -y \
		"https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" \
		"https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"
	ok "RPM Fusion enabled"
fi
