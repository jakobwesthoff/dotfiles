# Shell functions that rely on macOS (Yoink, drutil, diskutil).

# Allow to "Yoink" something directly from my commandline either by specifying it or using fzf in the current directory
yoink() {
    if [ "$#" -gt 0 ]; then
        open -a Yoink "$@"
    else
        local result
        result="$(fzf)"
        if [ -n "${result}" ]; then
            open -a Yoink "${result}"
        fi
    fi
}

# Eject the optical drive and do not return until the disc is really out.
#
# The old `alias eject="drutil eject"` was fire-and-forget: per man drutil,
# `eject` is a synonym for `drutil tray eject`, which hands the drive a tray
# command and exits 0 straight away. It exits 0 even when a still-mounted
# volume makes macOS refuse the request, which is precisely the situation
# right after something has read the disc. In `rip-disc && eject && next-step`
# the next step therefore starts with the disc still in the drive.
#
# So: unmount first (diskutil, unlike drutil, reports a busy volume), then
# ask for the eject, then poll the drive until it confirms the media is gone.
#
# Usage: eject [timeout-seconds]   (default 60, applied per phase)
eject() {
    local timeout="${1:-60}"
    local deadline

    # Empty drive: nothing to unmount and nothing to wait for, but keep the
    # old alias' convenience of opening the tray so a disc can go in.
    if drutil status 2>/dev/null | grep -q 'No Media Inserted'; then
        drutil tray open >/dev/null 2>&1
        return 0
    fi

    # drutil status prints the media's device node as "Name: /dev/diskN".
    local device
    device="$(drutil status 2>/dev/null |
        sed -n 's|.*Name: *\(/dev/[a-z0-9]*\).*|\1|p' |
        head -n1)"

    # Drive the loop off what is actually mounted rather than off diskutil's
    # exit status. A disc that is inserted but unmounted, or whose filesystem
    # macOS cannot read at all, never makes unmountDisk report success, and
    # would otherwise sit out the entire timeout for no reason.
    if [ -n "${device}" ]; then
        deadline=$((SECONDS + timeout))
        while mount | grep -qE "^${device}(s[0-9]+)* "; do
            if diskutil unmountDisk "${device}" >/dev/null 2>&1; then
                continue
            fi
            if [ "${SECONDS}" -ge "${deadline}" ]; then
                echo "eject: ${device} still busy after ${timeout}s, forcing" >&2
                diskutil unmountDisk force "${device}" >/dev/null || return 1
                break
            fi
            sleep 1
        done
    fi

    drutil eject >/dev/null 2>&1

    deadline=$((SECONDS + timeout))
    while ! drutil status 2>/dev/null | grep -q 'No Media Inserted'; do
        if [ "${SECONDS}" -ge "${deadline}" ]; then
            echo "eject: drive still reports media after ${timeout}s" >&2
            return 1
        fi
        sleep 1
    done
}
