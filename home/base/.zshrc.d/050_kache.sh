# kache: compiler cache for Rust and C/C++ (https://github.com/kunobi-ninja/kache)
#
# The Rust side lives in ~/.cargo/config.toml (`rustc-wrapper = "kache"`),
# written by `kache init`. These are the shell parts `kache init` writes
# into ~/.zshrc, which it refuses to edit because the file is a stow
# symlink. Machines without kache skip the whole module silently.
#
# Install and set up on a new machine: setup/base/setup.d/210-kache.sh
# in this repository, run by setup.sh.
#
# The test runner variable names the target triple, so each platform
# layer sets it in its own .zshrc.d/051_kache-runner.sh.

if (( $+commands[kache] )); then

    # Completions. 000_compinit.sh has run compinit already, so the guard
    # below normally finds compdef and skips the second compinit.
    if [[ -o interactive && -r "${HOME}/.local/share/kache/completions/kache.zsh" ]]; then
        if (( ! $+functions[compdef] )); then
            autoload -Uz compinit
            compinit
        fi
        source "${HOME}/.local/share/kache/completions/kache.zsh"
    fi

    # Compiler shims in front of PATH: cc, c++, gcc, g++, clang, clang++,
    # rustdoc and cargo resolve to kache, which runs the real tool found
    # further down PATH. Through the cargo shim kache knows which target
    # directories are in use and leaves them alone when it frees disk space.
    if [[ -d "${HOME}/.local/lib/kache/shims" ]]; then
        case "$PATH" in
            "${HOME}/.local/lib/kache/shims"|"${HOME}/.local/lib/kache/shims":*) ;;
            *) export PATH="${HOME}/.local/lib/kache/shims${PATH:+:$PATH}" ;;
        esac
    fi

fi
