# shellcheck shell=bash
# description: Link the dotfiles into $HOME (link.sh)

# The same layer setup.sh runs for; link.sh resolves the chain itself.
"${DOTFILES_DIR}/link.sh" "${DOTFILES_SETUP_LAYER}"
