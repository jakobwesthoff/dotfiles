# shellcheck shell=bash
# description: Install the dnf packages from packages.txt

mapfile -t packages < <(list_entries packages.txt)
info "Installing ${#packages[@]} packages..."
sudo dnf install -y "${packages[@]}"
ok "packages.txt installed"
