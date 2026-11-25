#!/bin/bash
set -euo pipefail

# Gets a fresh machine to the point where setup.sh can run: makes sure
# git exists, clones this repository into ~/dotfiles and starts setup.sh.
# Meant to be piped from GitHub:
#
#   curl -fsSL https://raw.githubusercontent.com/jakobwesthoff/dotfiles/main/bootstrap.sh | bash
#   curl -fsSL …/bootstrap.sh | bash -s -- <layer>    # pass a layer to setup.sh
#
# Runs on the system's own bash, which on a fresh Mac is bash 3.2.

target="$HOME/dotfiles"

# =========================================================
# git
# =========================================================

case "$(uname -s)" in
	Darwin)
		# git ships with the Xcode Command Line Tools; /usr/bin/git without
		# them only opens the installer dialog.
		if ! xcode-select -p >/dev/null 2>&1; then
			echo "Installing the Xcode Command Line Tools (confirm the dialog that opens)..."
			xcode-select --install
			until xcode-select -p >/dev/null 2>&1; do
				sleep 5
			done
		fi
		;;
	Linux)
		if ! command -v git >/dev/null 2>&1; then
			if grep -q '^ID=fedora$' /etc/os-release 2>/dev/null; then
				sudo dnf install -y git
			else
				echo "Install git first; this bootstrap knows only macOS and Fedora." >&2
				exit 1
			fi
		fi
		;;
	*)
		echo "Unsupported system: $(uname -s)" >&2
		exit 1
		;;
esac

# =========================================================
# Clone
# =========================================================

# Cloned over HTTPS, which needs no key; pushes go over SSH once a key
# for GitHub exists.
if [ -d "${target}/.git" ]; then
	echo "Using the existing checkout in ${target}"
else
	git clone https://github.com/jakobwesthoff/dotfiles.git "${target}"
	git -C "${target}" remote set-url --push origin git@github.com:jakobwesthoff/dotfiles.git
fi

# =========================================================
# Setup
# =========================================================

# Piped into bash, this script's stdin is the download, not the
# terminal; setup.sh asks questions, so it reads from the terminal.
exec "${target}/setup.sh" "$@" </dev/tty
