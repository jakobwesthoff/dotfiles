# shellcheck shell=bash
# description: Install the tools from every layer's tools.txt (cargo, go, npm)

# cargo from rustup (each OS layer's 200-rustup step), go install's
# ~/go/bin and npm's ~/.local/bin prefix all have to be reachable while
# the tools build.
# shellcheck source=/dev/null
. "$HOME/.cargo/env"
export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"

# One step for all layers: base lists what every machine gets, an OS
# layer adds what its package manager lacks, a host layer could add more.
# A failing tool does not stop the others; the step fails at the end so
# the run stops before anything that might rely on them.
tools_failed=0
while IFS= read -r layer; do
	list="${DOTFILES_DIR}/setup/${layer}/tools.txt"
	[ -f "${list}" ] || continue
	info "Tools of ${layer}"
	while read -r manager arguments; do
		read -ra args <<<"${arguments}"
		info "${manager}: ${arguments}..."
		case "${manager}" in
			cargo) command=(cargo install --locked "${args[@]}") ;;
			go)    command=(go install "${args[@]}") ;;
			npm)   command=(npm install --global --prefix "$HOME/.local" "${args[@]}") ;;
			*)
				fail "unknown manager '${manager}' in ${layer}/tools.txt"
				tools_failed=$((tools_failed + 1))
				continue
				;;
		esac
		if "${command[@]}" </dev/null; then
			ok "${arguments}"
		else
			fail "${arguments}"
			tools_failed=$((tools_failed + 1))
		fi
	done < <(list_entries "${list}")
done < <(layer_chain "${DOTFILES_SETUP_LAYER}")

if [ "${tools_failed}" -gt 0 ]; then
	fail "${tools_failed} tool(s) failed to install"
	exit 1
fi
ok "All tools installed"
