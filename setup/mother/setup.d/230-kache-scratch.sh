# shellcheck shell=bash
# description: Put kache's cache store on /scratch

# kache merges /etc/kache/config.toml under the user config key by key,
# so the shared ~/.config/kache/config.toml from home/base stays the same
# on every machine while this host adds the store location. The kache
# daemon runs as a systemd user service and reads the file too; a shell
# variable would not reach it.
store="/scratch/${USER}/kache"
host_config=/etc/kache/config.toml
setting="local_store = \"${store}\""

if sudo grep -qF "${setting}" "${host_config}" 2>/dev/null; then
	skip "${host_config} already points the store at ${store}"
elif sudo test -e "${host_config}"; then
	fail "${host_config} exists with other content; add this by hand under [cache]:"
	info "${setting}"
	exit 1
else
	sudo mkdir -p /etc/kache
	printf '[cache]\n%s\n' "${setting}" | sudo tee "${host_config}" >/dev/null
	ok "${host_config} points the store at ${store}"
fi

# The store that kache filled before this step (default ~/.cache/kache)
# moves along, so its cache hits stay. The daemon keeps its socket and
# state in the store, so it is stopped for the move and started again
# with the new location.
old_store="$HOME/.cache/kache"
if [ -d "${old_store}" ] && [ ! -e "${store}" ]; then
	info "Moving ${old_store} to ${store}..."
	systemctl --user stop kache.service 2>/dev/null || true
	mv "${old_store}" "${store}"
	systemctl --user start kache.service 2>/dev/null || true
	ok "Store moved to ${store}"
elif [ -d "${old_store}" ]; then
	warn "Both ${old_store} and ${store} exist; ${old_store} is no longer used and can be removed"
else
	mkdir -p "${store}"
	systemctl --user restart kache.service 2>/dev/null || true
	ok "Store at ${store}"
fi
