# shellcheck shell=sh
# Put Go-installed binaries (default GOPATH) ahead of Homebrew so locally
# built tool variants win over their bottled counterparts (e.g. a sesh built
# from the fork checkout with changes not yet released upstream).
if [ -d "$HOME/go/bin" ]; then
    export PATH="$HOME/go/bin:$PATH"
fi
