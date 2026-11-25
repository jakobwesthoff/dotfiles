# shellcheck shell=bash
# Helpers shared by setup.sh, link.sh, the presetups and the setup steps.
#
# Sourced, never executed. Everything here runs under macOS' /bin/bash
# 3.2 too, because setup.sh needs it before a presetup has installed a
# current bash: no mapfile, no associative arrays, no ${var,,}.

# The repository root, derived from this file's location so callers may
# run from any directory.
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export DOTFILES_DIR

# =========================================================
# Output
# =========================================================

bold='\033[1m'
dim='\033[2m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
red='\033[31m'
reset='\033[0m'

section() { printf "\n${bold}${blue}==> %s${reset}\n" "$1"; }
info()    { printf "  ${dim}%s${reset}\n" "$1"; }
ok()      { printf "  ${green}ok${reset} %s\n" "$1"; }
skip()    { printf "  ${dim}skip${reset} %s\n" "$1"; }
warn()    { printf "  ${yellow}!!${reset} %s\n" "$1"; }
fail()    { printf "  ${red}FAIL${reset} %s\n" "$1"; }
ask()     { printf "\n  ${yellow}>>>${reset} %s\n" "$1"; }

# =========================================================
# Layers
# =========================================================

# Prints the layer this machine uses: the given name, or the short
# hostname when no name is given. Fails with a hint when there is no
# layers/<name> file, so a new machine gets its own layer on purpose
# rather than by guessing.
machine_layer() {
	local name="${1:-$(hostname -s)}"
	if [ ! -f "${DOTFILES_DIR}/layers/${name}" ]; then
		fail "No layer '${name}' (expected ${DOTFILES_DIR}/layers/${name})" >&2
		info "Create it with the name of its parent layer as content," >&2
		info "e.g. 'echo fedora > layers/${name}', or pass a layer name." >&2
		return 1
	fi
	printf '%s\n' "${name}"
}

# Prints the chain of layers from the root down to the given layer, one
# per line: base, then the OS layer, then the host layer. Each
# layers/<name> file holds the name of its parent; base's file is empty.
layer_chain() {
	local name="$1"
	local chain=""
	local depth=0
	while [ -n "${name}" ]; do
		if [ ! -f "${DOTFILES_DIR}/layers/${name}" ]; then
			fail "Layer '${name}' is named as a parent but layers/${name} does not exist" >&2
			return 1
		fi
		# A parent loop would never end; ten levels are far more than
		# base, OS and host need.
		depth=$((depth + 1))
		if [ "${depth}" -gt 10 ]; then
			fail "Layer chain deeper than 10, probably a loop in layers/" >&2
			return 1
		fi
		chain="${name}${chain:+ ${chain}}"
		name=$(tr -d '[:space:]' <"${DOTFILES_DIR}/layers/${name}")
	done
	# Layer names contain no spaces, so splitting the list is safe.
	# shellcheck disable=SC2086
	printf '%s\n' ${chain}
}

# =========================================================
# Lists
# =========================================================

# Prints the non-comment, non-blank lines of a list file, with comments
# and surrounding whitespace removed.
list_entries() {
	sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$' || true
}
