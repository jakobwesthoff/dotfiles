# shellcheck shell=bash
# description: Set up rustup with the stable toolchain and rust-analyzer

# rustup-init comes from Fedora's rustup package (packages.txt).
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
