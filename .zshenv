# =============================================================================
# Zsh Environment Configuration (.zshenv)
# =============================================================================
#
# This file is sourced FIRST by zsh, before /etc/zshrc and ~/.zshrc.
# It's the correct place for environment variables that must be set early.
#
# Zsh startup file order:
#   1. /etc/zshenv
#   2. ~/.zshenv        <-- THIS FILE
#   3. /etc/zprofile
#   4. ~/.zprofile
#   5. /etc/zshrc
#   6. ~/.zshrc
#
# =============================================================================

# -----------------------------------------------------------------------------
# Disable macOS Shell Sessions
# -----------------------------------------------------------------------------
#
# CRITICAL: This MUST be set here in .zshenv, NOT in .zshrc!
#
# macOS includes Apple's shell session management in /etc/zshrc_Apple_Terminal.
# This system:
#   - Saves per-terminal session history to ~/.zsh_sessions/
#   - Attempts to merge session histories into the global ~/.zsh_history
#   - Truncates history files based on SAVEHIST (default: 1000)
#
# PROBLEM: When set in .zshrc, it's too late - the session hooks are already
# installed by /etc/zshrc before .zshrc runs. This causes:
#   - History corruption/truncation to 1000 entries
#   - Bulk imports with identical timestamps when sessions restore
#   - Loss of command history periodically
#
# By setting it here in .zshenv, we disable the session machinery BEFORE
# /etc/zshrc_Apple_Terminal runs, preventing all history-related issues.
#
# See: /etc/zshrc_Apple_Terminal for Apple's implementation
# See: https://apple.stackexchange.com/questions/427561/
#
export SHELL_SESSIONS_DISABLE=1
export SHELL_SESSION_HISTORY=0
