# Mount and cd into SMB shares by name
smb-mount() {
    local host="$1"
    local username="$2"
    shift 2

    if [ "$#" -lt 1 ]; then
        smbutil view "//$host" | awk '$2 == "Disk" {print $1}'
        return
    fi

    for share in "$@"; do
        echo "Mounting //$username@$host/$share"
        osascript -e 'mount volume "smb://'"$username"'@'"$host"'/'"$share"'"' >/dev/null
    done

    if [ "$#" -eq 1 ]; then
        cd "/Volumes/$1" || return
        pwd | clipcopy
    fi
}

zocalo() {
    smb-mount zocalo jakob "$@"
}
