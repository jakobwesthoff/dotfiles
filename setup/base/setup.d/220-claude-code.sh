# shellcheck shell=bash
# description: Install Claude Code with the native installer

if [ -x "$HOME/.local/bin/claude" ]; then
	skip "Claude Code already installed (it updates itself)"
else
	info "Installing Claude Code..."
	curl -fsSL https://claude.ai/install.sh | bash
	ok "Claude Code installed"
fi
