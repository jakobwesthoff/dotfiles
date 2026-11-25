#!/bin/bash
set -euo pipefail

# Sets up this machine: the setup steps of every layer from base down to
# the machine's own layer, chosen in a checklist and run in order.
#
#   ./setup.sh            layer named after the short hostname
#   ./setup.sh <layer>    a given layer, e.g. on a new machine
#
# The run has two phases. The first runs on whatever bash the system
# has, which on a fresh Mac is /bin/bash 3.2: it finds the layers and
# runs each layer's presetup.sh, which installs a current bash and
# dialog. Then the script starts itself again in that bash for the
# second phase: the checklist and the steps.

# shellcheck source-path=SCRIPTDIR source=setup/lib.sh
. "$(cd "$(dirname "$0")" && pwd)/setup/lib.sh"

layer=$(machine_layer "${1:-}")
# Steps such as base's 900-link.sh act on the same layer.
export DOTFILES_SETUP_LAYER="${layer}"
chain=()
while IFS= read -r name; do
	chain+=("${name}")
done < <(layer_chain "${layer}")

# =========================================================
# Phase 1: presetups (bash 3.2 compatible)
# =========================================================

# Prints the path of a bash 4 or newer: the running one, or the one a
# presetup installed through Homebrew.
modern_bash() {
	if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
		printf '%s\n' "${BASH}"
		return 0
	fi
	local candidate
	for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
		# The version check runs inside the candidate bash, hence the
		# single quotes.
		# shellcheck disable=SC2016
		if [ -x "${candidate}" ] && "${candidate}" -c '[ "${BASH_VERSINFO[0]}" -ge 4 ]'; then
			printf '%s\n' "${candidate}"
			return 0
		fi
	done
	return 1
}

if [ -z "${DOTFILES_SETUP_PHASE2:-}" ]; then
	printf '\n%b' "${bold}"
	echo "  -------------------------------------------------------------"
	echo "  Machine setup by Jakob Westhoff"
	echo "  Quite specific and opinionated. Will not work for everyone."
	echo "  -------------------------------------------------------------"
	printf '%b\n' "${reset}"
	info "Layers: ${chain[*]}"
	ask "Press ENTER to continue, Ctrl-C to abort"
	read -r

	for name in "${chain[@]}"; do
		presetup="${DOTFILES_DIR}/setup/${name}/presetup.sh"
		if [ -f "${presetup}" ]; then
			section "Presetup: ${name}"
			(
				cd "${DOTFILES_DIR}/setup/${name}"
				# shellcheck source=/dev/null
				. "${presetup}"
			)
		fi
	done

	if ! bash_path=$(modern_bash); then
		fail "No bash 4 or newer found after the presetups"
		exit 1
	fi
	export DOTFILES_SETUP_PHASE2=1
	exec "${bash_path}" "$0" "${layer}"
fi

# =========================================================
# Phase 2: choose and run the steps (bash 4 or newer)
# =========================================================

# Collect the steps of all layers as "number<TAB>chain position<TAB>
# layer<TAB>file<TAB>description" and sort them by number, then by chain
# position, so for the same number base runs before the OS layer before
# the host layer.
steps=()
for position in "${!chain[@]}"; do
	name="${chain[$position]}"
	for file in "${DOTFILES_DIR}/setup/${name}/setup.d/"*.sh; do
		[ -e "${file}" ] || continue
		base=$(basename "${file}")
		description=$(sed -n 's/^# description: //p' "${file}" | head -n 1)
		steps+=("$(printf '%s\t%s\t%s\t%s\t%s' "${base%%-*}" "${position}" "${name}" "${file}" "${description:-${base}}")")
	done
done
mapfile -t steps < <(printf '%s\n' "${steps[@]}" | sort -t $'\t' -k1,1n -k2,2n)

if [ "${#steps[@]}" -eq 0 ]; then
	warn "No setup steps for ${chain[*]}"
	exit 0
fi

# dialog draws on stdout and writes the chosen tags to stderr; swap the
# two so the command substitution captures the tags while the checklist
# reaches the terminal (fd 3 holds the original stdout).
items=()
for index in "${!steps[@]}"; do
	IFS=$'\t' read -r number _ name _ description <<<"${steps[$index]}"
	items+=("${index}" "${name} ${number}: ${description}" on)
done
exec 3>&1
if ! chosen=$(dialog --backtitle "setup.sh: ${chain[*]}" --separate-output \
	--checklist "Steps to run (Space toggles, Enter starts)" 0 0 0 \
	"${items[@]}" 2>&1 1>&3); then
	exec 3>&-
	clear
	info "Aborted, nothing was run."
	exit 0
fi
exec 3>&-
clear

if [ -z "${chosen}" ]; then
	info "No step chosen."
	exit 0
fi

# Many steps need sudo; ask once and keep the timestamp fresh for the
# whole run, since dnf, brew and cargo steps take long enough for it to
# expire in between.
sudo -v
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

# Each step runs in its own subshell from its layer's setup directory,
# so a step cannot leak variables or a changed directory into the next.
# A failing step stops the run: later steps may depend on it, and every
# step skips what is already done, so rerunning after a fix is cheap.
#
# The chosen indexes come in on fd 4, not stdin: stdin stays the
# terminal, so a step that asks for ENTER reads the keyboard instead of
# swallowing the next step's index.
while IFS= read -r index <&4; do
	IFS=$'\t' read -r number _ name file description <<<"${steps[$index]}"
	section "${name} ${number}: ${description}"
	if ! (
		set -euo pipefail
		cd "${DOTFILES_DIR}/setup/${name}"
		# shellcheck source=/dev/null
		. "${file}"
	); then
		fail "${name}/setup.d/$(basename "${file}") failed, the run stops here"
		info "Fix the cause and run ./setup.sh again; finished steps skip themselves."
		exit 1
	fi
done 4<<<"${chosen}"

printf '\n%b  Done!%b\n\n' "${bold}${green}" "${reset}"
