# =============================================================================
# Zsh Profile Configuration (.zprofile)
# =============================================================================
#
# Sourced for login shells, AFTER /etc/zprofile (which runs path_helper).
# This is the correct place on macOS for PATH and environment setup — it runs
# after path_helper has set system defaults, so our additions take precedence.
#
# Interactive-only config (aliases, completions, keybindings) stays in .zshrc.d.
#
# Zsh startup file order:
#   1. /etc/zshenv
#   2. ~/.zshenv        — shell session disable (must run before /etc/zshrc)
#   3. /etc/zprofile    — path_helper sets system PATH here
#   4. ~/.zprofile      <-- THIS FILE (PATH, env vars, brew shellenv)
#   5. /etc/zshrc
#   6. ~/.zshrc         — interactive config (.zshrc.d/)
#
# =============================================================================

# Source .zprofile.d
while read -rd $'\0' file; do
    source "${file}"
done < <(find -L "${HOME}/.zprofile.d" -mindepth 1 -maxdepth 1 -name '*.sh' -type f -print0 | LC_ALL=C sort -z)
