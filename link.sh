#!/usr/bin/env bash
set -euo pipefail

# Links the dotfiles of this machine into $HOME: home/<layer> of every
# layer from base down to the machine's own layer, stowed in that order.
#
#   ./link.sh            layer named after the short hostname
#   ./link.sh <layer>    a given layer, e.g. on a new machine

# shellcheck source-path=SCRIPTDIR source=setup/lib.sh
. "$(cd "$(dirname "$0")" && pwd)/setup/lib.sh"

layer=$(machine_layer "${1:-}")
chain=()
while IFS= read -r name; do
	chain+=("${name}")
done < <(layer_chain "${layer}")

section "Linking dotfiles for ${chain[*]}"

# Clones colorizer, prettytable and zgenom, and creates ~/bin as a real
# directory before stow sees it (see that script).
"${DOTFILES_DIR}/setup/checkout_dependencies.sh"
ok "Dependencies checked out"

# Only layers with something to link have a home/ directory.
packages=()
for name in "${chain[@]}"; do
	if [ -d "${DOTFILES_DIR}/home/${name}" ]; then
		packages+=("${name}")
	fi
done

# The dry run catches every conflict (a file already in $HOME, the same
# path in two layers) before anything changes, so a refused run leaves
# $HOME as it was.
if ! stow -n -R -d "${DOTFILES_DIR}/home" -t "${HOME}" "${packages[@]}"; then
	fail "stow reports conflicts, nothing was changed"
	info "Move the files named above out of the way, then run link.sh again."
	exit 1
fi
stow -R -d "${DOTFILES_DIR}/home" -t "${HOME}" "${packages[@]}"
ok "Stowed ${packages[*]}"
