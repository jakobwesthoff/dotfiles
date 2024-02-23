_ARCHEY_CACHE="${HOME}/.archey_cache"
#_ARCHEY_CACHE_TIMEOUT=1800
_ARCHEY_CACHE_TIMEOUT=60
_ARCHEY_EXECUTABLE="$(which archey)"

function _archey_update_cache() {
    "${_ARCHEY_EXECUTABLE}" -o -c 2>&1 >"${_ARCHEY_CACHE}"
}

function _archey_show() {
    if [ ! -f "${_ARCHEY_CACHE}" ]; then
        _archey_update_cache
    else 
        local cache_time="$(stat --printf=%Y "${_ARCHEY_CACHE}")"
        local now="$(date +%s)"

        if [ $((now - cache_time)) -ge ${_ARCHEY_CACHE_TIMEOUT} ]; then
            _archey_update_cache
        fi
    fi

    cat "${_ARCHEY_CACHE}"

    # Defer a cache update every time we are executed
    (_archey_update_cache &)
}
