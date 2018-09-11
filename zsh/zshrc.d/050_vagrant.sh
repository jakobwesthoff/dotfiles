# Display running vagrant vms once a shell is spawned
# The result is "intelligently" cached and defered, as the retrieval takes
# quite some time, which is kind of annoying upon each new shell instantiation.

_VAGRANT_RUNNING_CACHE="${HOME}/.vagrant_running_cache"
_VAGRANT_RUNNING_CACHE_BOOTTIME="${HOME}/.vagrant_running_cache_boottime"
_VAGRANT_EXECUTABLE="$(which vagrant)"

function _vagrant_get_cached_boottime() {
    local boottime="0"
    if [ -f "${_VAGRANT_RUNNING_CACHE_BOOTTIME}" ]; then
        boottime="$(cat "${_VAGRANT_RUNNING_CACHE_BOOTTIME}")"
    fi
    echo -n "${boottime//[$'\t\r\n ']}"
}

function _vagrant_get_boottime() {
    local full_boot_time="$(sysctl -a|grep kern.boottime)"
    local isolatedBootTime="${full_boot_time#*sec = }"
    isolatedBootTime="${isolatedBootTime%%,*}"
    echo -n "${isolatedBootTime//[$'\t\r\n ']}"
}

function _vagrant_update_cache() {
    "${_VAGRANT_EXECUTABLE}" global-status --prune 2>&1 >"${_VAGRANT_RUNNING_CACHE}"
    _vagrant_get_boottime >"${_VAGRANT_RUNNING_CACHE_BOOTTIME}"
}

function _vagrant_read_cache() {
    _VAGRANT_GLOBAL_STATUS="$(cat "${_VAGRANT_RUNNING_CACHE}")"
    _VAGRANT_GLOBAL_STATUS_CACHE_TIME="$(stat --printf=%Y "${_VAGRANT_RUNNING_CACHE}")"
}

function _vagrant_clear_cache() {
    if [ -f "${_VAGRANT_RUNNING_CACHE}" ]; then
        rm -f "${_VAGRANT_RUNNING_CACHE}"
    fi
    if [ -f "${_VAGRANT_RUNNING_CACHE_BOOTTIME}" ]; then
        rm -f "${_VAGRANT_RUNNING_CACHE_BOOTTIME}"
    fi
}

function _vagrant_get_status() {
    if [ ! -f "${_VAGRANT_RUNNING_CACHE}" ] || [ "$(_vagrant_get_cached_boottime)" -lt "$(_vagrant_get_boottime)" ]; then
        _vagrant_update_cache
    fi
    _vagrant_read_cache

    # Defer a cache update in case we missed a vagrant command ;)
    (_vagrant_update_cache &)

    echo -e "${_VAGRANT_GLOBAL_STATUS}"
}

function vagrant() {
    _vagrant_clear_cache
    "${_VAGRANT_EXECUTABLE}" "$@"
}


function _vagrant_show_status() {
    echo -ne "Scanning for running Vagrant VMs..."
    _VAGRANT_RUNNING_VMS="$(_vagrant_get_status|sed -e '/^\s*$/q'|grep --color=never 'running')"
    echo -ne "\\r                                                                               \\r"
    if [ "$(echo -e "${_VAGRANT_RUNNING_VMS}"|wc -c)" -gt "1" ]; then
        colorize "<green>Running vagrant vms:</green>"
        {
            echo -e  "id\tname\tprovider\tstate\tdirectory"
            echo -e "${_VAGRANT_RUNNING_VMS}" | sed -e "s@^\\([^\s]\\+\\)\\s\\+\\([^\s]\\+\\)\\s\\+\\([^\s]\\+\\)\\s\\+\\([^\s]\\+\\)\\s\\(.\\+\\)\$@\\1	\\2	\\3	\\4	\\5@"
        } | prettytable 5 "yellow"
        echo ""
    fi
}
