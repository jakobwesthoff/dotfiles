# shellcheck shell=bash
# description: Check SSH keys and their keychain integration

if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
	ok "SSH keys found"
	ssh-add --apple-use-keychain 2>/dev/null || true
else
	warn "No SSH keys found in ~/.ssh (expected id_rsa or id_ed25519)"
	ask "Add your SSH private keys, then press ENTER"
	read -r
	ssh-add --apple-use-keychain
fi

if grep -q "UseKeychain yes" ~/.ssh/config 2>/dev/null; then
	ok "SSH config has UseKeychain"
else
	warn "$HOME/.ssh/config is missing UseKeychain/AddKeysToAgent"
	info "Ensure your Host * block includes:"
	info "  UseKeychain yes"
	info "  AddKeysToAgent yes"
	ask "Press ENTER when done"
	read -r
fi
