# shellcheck shell=bash
# description: Install the Ghostty terminfo entry (xterm-ghostty) system-wide

# Fedora's ncurses does not know Ghostty, so zsh, tmux, nvim and less
# misbehave in a session started from Ghostty. The entry goes into
# /etc/terminfo, the directory for locally added entries: a login shell
# started by sshd runs in secure mode (AT_SECURE, from the SELinux domain
# transition), in which ncurses ignores ~/.terminfo, so zsh itself would
# not find an entry there. xterm-ghostty.terminfo is
# `infocmp -x xterm-ghostty` taken on a Mac with Ghostty installed.
if [ -e /etc/terminfo/x/xterm-ghostty ]; then
	skip "xterm-ghostty already in /etc/terminfo"
else
	sudo tic -x -o /etc/terminfo xterm-ghostty.terminfo
	ok "xterm-ghostty compiled into /etc/terminfo"
fi
