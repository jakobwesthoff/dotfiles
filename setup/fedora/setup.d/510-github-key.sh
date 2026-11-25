# shellcheck shell=bash
# description: Create an SSH key for GitHub and show it

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
