#!/bin/bash
set -uio pipefail

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
echo "Installing zgen"
checkout_or_update https://github.com/tarjoilija/zgen.git .zgen

echo
echo "Installing solarized dircolors"
checkout_or_update https://github.com/seebi/dircolors-solarized.git .dircolors-solarized
[ ! -f "${HOME}/.dircolors" ] && ln -s "${HOME}/.dircolors-solarized/dircolors.ansi-light" "${HOME}/.dircolors"

echo
echo "Installing nvm"
checkout_or_update https://github.com/creationix/nvm.git .nvm

popd &>/dev/null
