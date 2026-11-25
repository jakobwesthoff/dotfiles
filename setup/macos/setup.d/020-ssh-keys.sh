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

# ~/.ssh/config names private hosts, so it stays out of this public
# repository; the step only makes sure the keychain lines are in it.
# ssh takes the first value it finds per option, so a Host * block at the
# end supplies these two without overriding any host-specific setting.
if grep -q "UseKeychain yes" ~/.ssh/config 2>/dev/null; then
	ok "SSH config has UseKeychain"
else
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	cat >>~/.ssh/config <<'SSHCONFIG'

Host *
  UseKeychain yes
  AddKeysToAgent yes
SSHCONFIG
	chmod 600 ~/.ssh/config
	ok "Added UseKeychain and AddKeysToAgent to ~/.ssh/config"
fi
