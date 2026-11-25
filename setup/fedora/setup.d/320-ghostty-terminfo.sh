# shellcheck shell=bash
# description: Install the Ghostty terminfo entry (xterm-ghostty) for this user

# Fedora's ncurses does not know Ghostty, so tmux, nvim and less
# misbehave in a session started from Ghostty. ncurses looks in
# ~/.terminfo first. xterm-ghostty.terminfo is `infocmp -x xterm-ghostty`
# taken on a Mac with Ghostty installed.
if infocmp xterm-ghostty &>/dev/null; then
	skip "xterm-ghostty already known"
else
	tic -x -o "$HOME/.terminfo" xterm-ghostty.terminfo
	ok "xterm-ghostty compiled into ~/.terminfo"
fi
