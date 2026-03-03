# Reset terminal mouse/reporting modes before each prompt.
#
# Some TUI applications enable mouse tracking (e.g., ?1003h any-event mode)
# and exit without disabling them. Inside tmux this causes Ghostty to flood
# tmux with spurious mouse events for every cursor movement, corrupting
# coordinate handling until the terminal process is restarted.
#
# This hook resets all standard mouse and focus-reporting modes to a clean
# state before each prompt, so the shell is always returned to a safe
# baseline regardless of what the previous command left behind.
if [[ -n "$TMUX" ]]; then
    function _reset_mouse_modes() {
        # Disable: X10 mouse, highlight mouse, button-event mouse,
        # any-event mouse, focus reporting, SGR mouse, urxvt mouse
        printf '\e[?1000l\e[?1001l\e[?1002l\e[?1003l\e[?1004l\e[?1006l\e[?1015l' > /dev/tty 2>/dev/null
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _reset_mouse_modes
fi
