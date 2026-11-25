# shellcheck shell=bash
# Presetup for macOS, sourced by setup.sh from setup/macos/ on the
# system's /bin/bash 3.2. Installs what setup.sh itself needs before it
# can show the checklist: the Xcode Command Line Tools (git, compilers),
# Homebrew, and through Homebrew a current bash, dialog, git and stow.

if [ "$(uname -s)" != "Darwin" ]; then
	fail "The macos layer runs on macOS only"
	exit 1
fi

if xcode-select -p &>/dev/null; then
	ok "Xcode Command Line Tools installed"
else
	info "Installing Xcode Command Line Tools (confirm the dialog that opens)..."
	xcode-select --install
	until xcode-select -p &>/dev/null; do
		sleep 5
	done
	ok "Xcode Command Line Tools installed"
fi

if [ -x /opt/homebrew/bin/brew ]; then
	ok "Homebrew already installed"
else
	info "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	ok "Homebrew installed"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

info "Installing bash, dialog, git and stow..."
brew install bash dialog git stow
ok "bash, dialog, git and stow ready"
