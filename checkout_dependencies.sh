#!/bin/bash
function checkout_or_update() {
    local repository="${1}"
    local target="${2}"

    if [ -d "${target}" ]; then
        pushd "${target}"
        git reset --hard
        git pull -f
        popd
    else
        git clone "${repository}" "${target}"
    fi
}

pushd ~
echo "Installing bash configuration dependencies"
checkout_or_update https://github.com/jakobwesthoff/colorizer.git .colorizer

echo
echo "Installing autojump"
checkout_or_update https://github.com/joelthelion/autojump.git .autojump

echo
echo "Installing solarized dircolors"
checkout_or_update https://github.com/seebi/dircolors-solarized.git .dircolors-solarized
popd
