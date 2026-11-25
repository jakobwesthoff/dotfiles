# shellcheck shell=bash
# description: Install the development-tools group (gcc, make, ...)

# Crates with C dependencies and Mason's tree-sitter builds need them.
sudo dnf group install -y development-tools
ok "Development tools installed"
