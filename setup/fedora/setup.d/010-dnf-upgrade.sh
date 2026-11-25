# shellcheck shell=bash
# description: Upgrade all packages (dnf upgrade)

info "Running dnf upgrade (this may take a while)..."
sudo dnf upgrade -y --refresh
ok "System up to date"
