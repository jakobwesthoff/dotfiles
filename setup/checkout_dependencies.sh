#!/bin/bash
set -ueo pipefail

function checkout_or_update() {
    local repository="${1}"
    local target="${2}"

    # The clones carry no work of their own, so an update simply moves them
    # to the upstream's default branch. Asking the remote which branch that
    # is, instead of pulling the branch the clone was made from, keeps the
    # update working when a dependency renames its default branch.
    if [ -d "${target}" ]; then
        pushd "${target}" &>/dev/null
        git fetch --quiet origin
        git remote set-head origin --auto >/dev/null
        git reset --hard origin/HEAD
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

# This runs before stow, so ~/bin is created as a real directory here and stow
# links the dotfiles' own scripts into it one by one instead of replacing it
# with a link to dotfiles/bin. Anything else placed in ~/bin, such as the
# yabai-center-single link below, would otherwise end up in the repository.
mkdir -p bin

# yabai is a macOS window manager, so its helper is useless anywhere else.
if [ "$(uname -s)" = "Darwin" ]; then
    echo
    echo "Installing yabai-center-single"
    checkout_or_update https://github.com/jakobwesthoff/yabai-center-single.git .yabai-center-single
    # .yabairc, .skhdrc and bin/yabai_recording call it as ~/bin/yabai_center_single,
    # and ~/bin is on PATH for running "yabai_center_single resume" by hand.
    ln -sfn "${HOME}/.yabai-center-single/bin/yabai_center_single" bin/yabai_center_single
fi

popd &>/dev/null
