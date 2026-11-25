# shellcheck shell=bash
# description: Install kache, the compiler cache for Rust and C/C++

# Runs after the OS layer's 200-rustup step, which provides cargo.
# shellcheck source=/dev/null
. "$HOME/.cargo/env"

if command -v kache &>/dev/null; then
	skip "kache already installed"
else
	info "Installing kache (this compiles for a while)..."
	cargo install kache --locked
	ok "kache installed"
fi

# --no-shell because the shell parts (shims on PATH, test runner,
# completions loading) live in .zshrc.d/050_kache.sh and the platform's
# 051_kache-runner.sh; kache init only writes ~/.cargo/config.toml and
# the login service here.
kache init --yes --no-shell
kache init --shims
mkdir -p "$HOME/.local/share/kache/completions"
kache completions zsh >"$HOME/.local/share/kache/completions/kache.zsh"
ok "kache set up with shims and zsh completions"
