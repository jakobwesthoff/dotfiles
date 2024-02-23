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

wait_for()
{
    if [ ${#} -ne 1 ]; then
        _r9e_print_message "usage: ${FUNCNAME} <hostname>"
        return 1
    fi

    local host="${1}"

    local wait_option='-w'
    if [ "$(uname)" = "Darwin" ]; then
        wait_option='-t'
    fi


    local nl=''
    while ! ping -qc1 "${wait_option}2" "${host}" >/dev/zero 2>&1; do
        # make sure we have a chance to cancel the loop:
        sleep 0.5

        _r9e_print_message -n '.'
        nl='\n'
    done

    _r9e_print_message "${nl}Host %s is now available" "${host}"
}
_r9e_set_completion_function wait_for _hosts
_r9e_set_completion_function wait_for _known_hosts

wait_for_port()
{
    if [ ${#} -ne 2 ]; then
        _r9e_print_message "usage: ${FUNCNAME} <hostname> <port>"
        return 1
    fi

    local host="${1}"
    local port="${2}"

    local nl=''
    while ! nc -zG 2 "${host}" "${port}" >/dev/zero; do
        # make sure we have a chance to cancel the loop:
        sleep 0.5

        _r9e_print_message -n '.'
        nl='\n'
    done

    _r9e_print_message "${nl}port %s on %s is now available" "${port}" "${host}"
}
_r9e_set_completion_function wait_for_port _hosts
_r9e_set_completion_function wait_for_port _known_hosts

wait_for_ssh()
{
    local host="$(ssh -G "${@}" | grep '^hostname ' | sed 's/^hostname //')"
    local port="$(ssh -G "${@}" | grep '^port ' | sed 's/^port //')"

    wait_for_port "${host}" "${port}"
    ssh "${@}"
}

if _r9e_is_shell_function '_ssh'; then
    _wait_for_ssh()
    {
        local service='ssh'
        _ssh
    }

    _r9e_set_completion_function wait_for_ssh _wait_for_ssh
fi

retag() {
    if [ "$#" -ne "1" ]; then
        echo "Provide a tag name!"
        return 1
    fi
    local TAG="$1"
    git push --delete origin "$TAG"
    git tag -d "$TAG";
    git tag "$TAG";
    git push --tags;
 }

rmtag() {
    if [ "$#" -ne "1" ]; then
        echo "Provide a tag name!"
        return 1
    fi
    local TAG="$1"

    git tag -d "$TAG"
    git push --delete origin "$TAG"
}

push_nexus() {
    if [ "$#" -ne "2" ]; then
        echo "Provide a image name and tag name!"
        return 1
    fi
    local image="$1"
    local tag="$2"

    docker pull registry.gitlab.com/ekkogmbh/artifacts/${image}:${tag} && \
    docker image tag registry.gitlab.com/ekkogmbh/artifacts/${image}:${tag} lpitdnexus01.bmwgroup.net:16052/epaper/${image}:${tag}  && \
    docker push lpitdnexus01.bmwgroup.net:16052/epaper/${image}:${tag}
}
