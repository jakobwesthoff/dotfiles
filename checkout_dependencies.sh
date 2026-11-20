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

echo
echo "Installing yabai-center-single"
checkout_or_update https://github.com/jakobwesthoff/yabai-center-single.git .yabai-center-single
# .yabairc, .skhdrc and bin/yabai_recording call it as ~/bin/yabai_center_single,
# and ~/bin is on PATH for running "yabai_center_single resume" by hand.
# This runs before stow, so ~/bin is created as a real directory here and stow
# links the dotfiles' own scripts into it one by one instead of replacing it
# with a link to dotfiles/bin, which would put this link into the repository.
mkdir -p bin
ln -sfn "${HOME}/.yabai-center-single/bin/yabai_center_single" bin/yabai_center_single

popd &>/dev/null
