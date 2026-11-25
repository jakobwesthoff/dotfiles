#!/bin/bash
set -euo pipefail

# Sets up a Fedora machine (written for mother, a headless Fedora Server)
# as a work box reached over SSH: system updates and repositories, the
# packages from packages.txt, the tools from tools.txt, Rust, nvm,
# Claude Code, SSH hardening, automatic security updates and the
# dotfiles checkout. Stowing the dotfiles stays a manual step, printed
# at the end.

setup_dir=$(cd "$(dirname "$0")" && pwd)

# =========================================================
# Output helpers
# =========================================================

bold='\033[1m'
dim='\033[2m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
red='\033[31m'
reset='\033[0m'

section() { printf "\n${bold}${blue}==> %s${reset}\n" "$1"; }
info()    { printf "  ${dim}%s${reset}\n" "$1"; }
ok()      { printf "  ${green}ok${reset} %s\n" "$1"; }
skip()    { printf "  ${dim}skip${reset} %s\n" "$1"; }
warn()    { printf "  ${yellow}!!${reset} %s\n" "$1"; }
fail()    { printf "  ${red}FAIL${reset} %s\n" "$1"; }
ask()     { printf "\n  ${yellow}>>>${reset} %s\n" "$1"; }

# Prints the non-comment, non-blank lines of a list file, with trailing
# comments and surrounding whitespace removed.
list_entries() {
	sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$'
}

# =========================================================
# Disclaimer
# =========================================================

if [[ "${1:-}" != "--yes" ]]; then
	printf '\n%b' "${bold}"
	echo "  -------------------------------------------------------------"
	echo "  Fedora Setup by Jakob Westhoff"
	echo "  Quite specific and opinionated. Will not work for everyone."
	echo "  -------------------------------------------------------------"
	printf '%b\n' "${reset}"
	ask "Press ENTER to continue"
	read -r
fi

# =========================================================
# Prerequisites
# =========================================================

section "Checking prerequisites"

if grep -q '^ID=fedora$' /etc/os-release; then
	ok "Running on $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"
else
	fail "This script is for Fedora only"
	exit 1
fi

# The sudo timestamp is kept fresh for the whole run, since dnf, cargo
# and npm steps together take long enough for it to expire in between.
sudo -v
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &
ok "sudo available"

# =========================================================
# System update and repositories
# =========================================================

section "System update"

info "Running dnf upgrade (this may take a while)..."
sudo dnf upgrade -y --refresh
ok "System up to date"

section "Repositories"

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

# =========================================================
# Packages
# =========================================================

section "Packages"

# gcc, make and the other basics that crates with C dependencies and
# Mason's tree-sitter builds rely on.
info "Installing the development-tools group..."
sudo dnf group install -y development-tools
ok "Development tools"

mapfile -t packages < <(list_entries "${setup_dir}/packages.txt")
info "Installing ${#packages[@]} packages from packages.txt..."
sudo dnf install -y "${packages[@]}"
ok "packages.txt installed"

# =========================================================
# Rust
# =========================================================

section "Rust"

# Toolchains live in ~/.rustup and cargo in ~/.cargo, the layout
# .zprofile.d/050_rust.sh expects. --no-modify-path because the shell
# configuration comes from the dotfiles.
if [ -x "$HOME/.cargo/bin/rustup" ]; then
	skip "rustup toolchain already initialised"
else
	info "Initialising rustup with the stable toolchain..."
	rustup-init -y --no-modify-path
	ok "rustup initialised"
fi
# shellcheck source=/dev/null
. "$HOME/.cargo/env"
rustup component add rust-analyzer
ok "Rust $(rustc --version | cut -d' ' -f2) with rust-analyzer"

# =========================================================
# Tools outside Fedora
# =========================================================

section "Tools outside Fedora"

# go install puts binaries into ~/go/bin and npm with this prefix into
# ~/.local/bin; both have to be reachable for the steps below.
export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"

tools_failed=0
while read -r manager arguments; do
	read -ra args <<<"${arguments}"
	info "${manager}: ${arguments}..."
	case "${manager}" in
		cargo) command=(cargo install --locked "${args[@]}") ;;
		go)    command=(go install "${args[@]}") ;;
		npm)   command=(npm install --global --prefix "$HOME/.local" "${args[@]}") ;;
		*)
			fail "unknown manager '${manager}' in tools.txt"
			tools_failed=$((tools_failed + 1))
			continue
			;;
	esac
	if "${command[@]}" </dev/null; then
		ok "${arguments}"
	else
		fail "${arguments}"
		tools_failed=$((tools_failed + 1))
	fi
done < <(list_entries "${setup_dir}/tools.txt")

if [ "${tools_failed}" -gt 0 ]; then
	warn "${tools_failed} tool(s) failed to install. Rerun the script or install them by hand."
else
	ok "All tools from tools.txt installed"
fi

# =========================================================
# nvm
# =========================================================

section "nvm"

# nvm's documented manual install: a git checkout in ~/.nvm on the latest
# release tag. Its install script would edit ~/.zshrc, which is a stow
# link into the dotfiles.
if [ -d "$HOME/.nvm/.git" ]; then
	info "Updating nvm..."
	git -C "$HOME/.nvm" fetch --tags --quiet
else
	info "Cloning nvm..."
	git clone --quiet https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
fi
nvm_tag=$(git -C "$HOME/.nvm" describe --abbrev=0 --tags --match "v[0-9]*" \
	"$(git -C "$HOME/.nvm" rev-list --tags --max-count=1)")
git -C "$HOME/.nvm" -c advice.detachedHead=false checkout --quiet "${nvm_tag}"
ok "nvm ${nvm_tag} in ~/.nvm"

# =========================================================
# Claude Code
# =========================================================

section "Claude Code"

if [ -x "$HOME/.local/bin/claude" ]; then
	skip "Claude Code already installed (it updates itself)"
else
	info "Installing Claude Code with the native installer..."
	curl -fsSL https://claude.ai/install.sh | bash
	ok "Claude Code installed"
fi

# =========================================================
# Shell
# =========================================================

section "Shell"

if [ "$(getent passwd "$USER" | cut -d: -f7)" = "/usr/bin/zsh" ]; then
	skip "zsh is already the login shell"
else
	sudo usermod -s /usr/bin/zsh "$USER"
	ok "zsh is the login shell (from the next login on)"
fi

# =========================================================
# SSH
# =========================================================

section "SSH"

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

# A key of the machine's own, so pushes to GitHub also work from tmux
# sessions that keep running after the SSH connection is gone.
if [ -f "$HOME/.ssh/id_ed25519" ]; then
	skip "SSH key ~/.ssh/id_ed25519 exists"
else
	info "Creating ~/.ssh/id_ed25519..."
	ssh-keygen -t ed25519 -C "${USER}@$(hostname -s)" -f "$HOME/.ssh/id_ed25519"
	ok "SSH key created"
fi
ask "Make sure this key is added to GitHub (https://github.com/settings/keys):"
cat "$HOME/.ssh/id_ed25519.pub"
echo "     Press ENTER to continue"
read -r

# =========================================================
# Automatic security updates
# =========================================================

section "Automatic updates"

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

# =========================================================
# Dotfiles
# =========================================================

section "Dotfiles"

mkdir -p "$HOME/Development/github/jakobwesthoff"

# Cloned over HTTPS, which needs no key; pushes go over SSH with the key
# from above.
if [ -d "$HOME/dotfiles" ]; then
	ok "Dotfiles already cloned"
else
	info "Cloning dotfiles..."
	git clone https://github.com/jakobwesthoff/dotfiles.git "$HOME/dotfiles"
	ok "Dotfiles cloned"
fi
git -C "$HOME/dotfiles" remote set-url --push origin git@github.com:jakobwesthoff/dotfiles.git

"$HOME/dotfiles/setup/checkout_dependencies.sh"
ok "Dotfiles dependencies checked out"

# =========================================================
# Next steps
# =========================================================

printf '\n%b  Done!%b\n\n' "${bold}${green}" "${reset}"
echo "  The dotfiles are not stowed yet. To link them into \$HOME:"
echo
echo "      cd ~/dotfiles"
echo "      stow -n -v .   # dry run: shows what would be linked"
echo "      stow ."
echo
echo "  stow refuses to overwrite existing files such as ~/.zshrc or"
echo "  ~/.bashrc. Move them aside first. The dotfiles still carry"
echo "  macOS-specific files and paths, which get linked as well."
echo
echo "  Log in again afterwards, so zsh starts as the login shell."
echo
