# Reversed tailf
#
# Usage: "flait logfile"
railf() {
    while true; do
        clear
        tail -n $(($LINES - 1)) $1 |
            tac |
            cut -c 1-$COLUMNS
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
#
# make a directory with prefixed date and cd to it
mkcdd() {
    local name
    name="$(date "+%Y_%m_%d")_${1}"
    if [ ! -d "${name}" ]; then
        mkdir -p "${name}"
    fi
    cd "${name}"
}

# Define a more convinient way of extracting colums using awk
# Usage column <colnumber> [<optional_column seperator>] < infile
col() {
    eval awk ${2:+"-F $2"} "'{print \$$1}'"
}

# In honor to Star-Trek
makeitso() {
    sudo $(history 2 | head -n 1 | sed -e 's@^[0-9]\+\s\+@@')
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

wait_for() {
    if [ ${#} -ne 1 ]; then
        echo "usage: ${FUNCNAME[0]} <hostname>"
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

        echo -n '.'
        nl='\n'
    done

    printf "${nl}Host %s is now available\n" "${host}"
}
compdef _hosts wait_for
compdef _known_hosts wait_for

wait_for_port() {
    if [ ${#} -ne 2 ]; then
        echo "usage: ${FUNCNAME[0]} <hostname> <port>"
        return 1
    fi

    local host="${1}"
    local port="${2}"

    local nl=''
    while ! nc -zG 2 "${host}" "${port}" >/dev/zero; do
        # make sure we have a chance to cancel the loop:
        sleep 0.5

        echo -n '.'
        nl='\n'
    done

    printf "${nl}port %s on %s is now available\n" "${port}" "${host}"
}
compdef _hosts wait_for_port
compdef _known_hosts wait_for_port

wait_for_ssh() {
    local host="$(ssh -G "${@}" | grep '^hostname ' | sed 's/^hostname //')"
    local port="$(ssh -G "${@}" | grep '^port ' | sed 's/^port //')"

    wait_for_port "${host}" "${port}"
    ssh "${@}"
}

_wait_for_ssh() {
    local service='ssh'
    _ssh
}

compdef _wait_for_ssh wait_for_ssh

retag() {
    if [ "$#" -ne "1" ]; then
        echo "Provide a tag name!"
        return 1
    fi
    local TAG="$1"
    git push --delete origin "$TAG"
    git tag -d "$TAG"
    git tag "$TAG"
    git push --tags
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

    docker pull registry.gitlab.com/ekkogmbh/artifacts/${image}:${tag} &&
        docker image tag registry.gitlab.com/ekkogmbh/artifacts/${image}:${tag} lpitdnexus01.bmwgroup.net:16052/epaper/${image}:${tag} &&
        docker push lpitdnexus01.bmwgroup.net:16052/epaper/${image}:${tag}
}

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

## Generic function to clone github or gitlab repositories to the correct dev folder on *my* system
## which currently is ~/Development/<github|gitlab>/<org|author>/<reponame>
##
## The function is usually called using the aliases ghclone and glclone
gitclone() {
    if [ "$#" -lt 2 ]; then
        echo "gitclone <gitlab|github> [--ssh] <ssh-url|http(s)-url|org/name>"
        return 1
    fi

    local ssh=""
    local mode=""
    local repo=""

    while [ "$#" -gt 0 ]; do
        if [[ "$1" == "--ssh" ]]; then
            ssh="true"
            shift
            continue
        fi

        if [ -z "$mode" ]; then
            mode="$1"
            shift
            continue
        fi

        if [ -z "$repo" ]; then
            repo="$1"
            shift
            continue
        fi

        break
    done

    # Extract org/name
    local org=""
    local name=""
    if [[ "${repo}" =~ ^https?://.+/(.+)/(.+)\.git$ ]]; then
        org="${match[1]}"
        name="${match[2]}"
    elif [[ "${repo}" =~ ^git@.+:(.+)/(.+)\.git$ ]]; then
        org="${match[1]}"
        name="${match[2]}"
        ssh="true"
    elif [[ "${repo}" =~ ^([^/]+)/([^/]+)$ ]]; then
        org="${match[1]}"
        name="${match[2]}"
    else
        echo "The given repository does not seem to be an http(s), ssh or org/name identifier: $repo"
        return 1
    fi

    if [[ "$mode" != "github" ]] && [[ "$mode" != "gitlab" ]]; then
        echo "Unsupported mode: $mode"
        return 1
    fi

    local target_without_name="${HOME}/Development/${mode}/${org}"
    local target="${target_without_name}/${name}"

    if [ -d "$target" ]; then
        echo "Target directory already exists. Just changing into it: ${target}"
        cd "${target}" || return 1
        return 0
    fi

    local url=""
    if [ -n "${ssh}" ]; then
        url="git@${mode}.com:${org}/${name}.git"
    else
        url="https://${mode}.com/${org}/${name}.git"
    fi

    mkcd "${target_without_name}"
    git clone "${url}" "${name}"
    cd "${name}" || return 1
}

ghclone() {
    gitclone github "$@"
}

glclone() {
    gitclone gitlab "$@"
}
