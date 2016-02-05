# Reversed tailf
#
# Usage: "flait logfile"
railf() {
    while true;do 
        clear
        tail -n $(($LINES-1)) $1 \
        | tac \
        | cut -c 1-$COLUMNS
        sleep 1
    done
}

# CD to a directory, but open it in vim, if it is a file
cd() {
    if [ -f "${1}" ]; then
        vim "${@}"
    else
        builtin cd "${@}"
    fi
}

# make a directory and cd to it
mkcd() {
    if [ ! -d "${1}" ]; then
        mkdir -p "${1}"
    fi
    cd "${1}"
}

# Define a more convinient way of extracting colums using awk
# Usage column <colnumber> [<optional_column seperator>] < infile
col() {
    eval awk ${2:+"-F $2"} "'{print \$$1}'";
}

# In honor to Star-Trek
makeitso() {
    sudo $(history 2|head -n 1|sed -e 's@^[0-9]\+\s\+@@')
}

# Copy current working directory to clipboard AND output it
cwd() {
    pwd | tr -d '\n' | pbcopy
    pwd
}

# Rename using a temporary step to overcome hfs case-insensitivity
mvcase() {
    local source="${1}"
    local destination="${2}"

    local uuid="$(uuidgen)"

    while [ -e "${source}.${uuid}" ]; do
        uuid="$(uuidgen)"
    done

    mv "${source}" "${source}.${uuid}"
    mv "${source}.${uuid}" "${destination}"
}

# Rename using a temporary step to overcome hfs case-insensitivity, but for git
gitmvcase() {
    local source="${1}"
    local destination="${2}"

    local uuid="$(uuidgen)"

    while [ -e "${source}.${uuid}" ]; do
        uuid="$(uuidgen)"
    done

    git mv "${source}" "${source}.${uuid}"
    git mv "${source}.${uuid}" "${destination}"
}
