#!/bin/bash
set -ueo pipefail

function checkout_or_update() {
    local repository="${1}"
    local target="${2}"

    if [ -d "${target}" ]; then
        pushd "${target}" &>/dev/null
        git reset --hard
        git pull -f
        popd &>/dev/null
    else
        git clone "${repository}" "${target}"
    fi
}

pushd "${HOME}" &>/dev/null
echo "Installing bash configuration dependencies"
checkout_or_update https://github.com/jakobwesthoff/colorizer.git .colorizer
checkout_or_update https://github.com/jakobwesthoff/prettytable.sh.git .prettytable

echo
echo "Installing zgenom"
checkout_or_update https://github.com/jandamm/zgenom.git .zgenom

popd &>/dev/null
