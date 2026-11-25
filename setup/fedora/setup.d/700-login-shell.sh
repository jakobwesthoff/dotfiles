# shellcheck shell=bash
# description: Make zsh the login shell

if [ "$(getent passwd "$USER" | cut -d: -f7)" = "/usr/bin/zsh" ]; then
	skip "zsh is already the login shell"
else
	sudo usermod -s /usr/bin/zsh "$USER"
	ok "zsh is the login shell (from the next login on)"
fi
