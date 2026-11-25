# shellcheck shell=sh
# Put Go-installed binaries (default GOPATH) ahead of Homebrew so locally
# built tool variants (e.g. a fork checkout with changes not yet released
# upstream) win over their bottled counterparts.
if [ -d "$HOME/go/bin" ]; then
    export PATH="$HOME/go/bin:$PATH"
fi
