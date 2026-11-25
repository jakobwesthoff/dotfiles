# shellcheck shell=bash
# description: Install rustup with the stable toolchain from rustup.rs

# rustup from rustup.rs rather than Homebrew: toolchains in ~/.rustup and
# cargo in ~/.cargo, the layout .zprofile.d/050_rust.sh expects.
# --no-modify-path because the shell configuration comes from the dotfiles.
if [ -x "$HOME/.cargo/bin/rustup" ]; then
	skip "rustup already installed"
else
	info "Installing rustup with the stable toolchain..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
	ok "rustup installed"
fi
