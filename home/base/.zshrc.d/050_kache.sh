# kache: compiler cache for Rust and C/C++ (https://github.com/kunobi-ninja/kache)
#
# The Rust side lives in ~/.cargo/config.toml (`rustc-wrapper = "kache"`),
# written by `kache init`. These are the shell parts `kache init` writes
# into ~/.zshrc, which it refuses to edit because the file is a stow
# symlink. Machines without kache skip the whole module silently.
#
# Install and set up on a new machine:
#   cargo install kache --locked    # or a pinned version: --version 2.1.1
#   kache init                      # ~/.cargo/config.toml and the login service
#   kache init --shims              # compiler-name links in ~/.local/lib/kache/shims
#   mkdir -p ~/.local/share/kache/completions
#   kache completions zsh > ~/.local/share/kache/completions/kache.zsh

if (( $+commands[kache] )); then

    # Test pacing: test binaries started by `cargo test` run through kache,
    # which holds them back until builds free their CPU slots. A runner set
    # elsewhere wins.
    [ -n "${CARGO_TARGET_AARCH64_APPLE_DARWIN_RUNNER-}" ] || CARGO_TARGET_AARCH64_APPLE_DARWIN_RUNNER='kache test-runner'; export CARGO_TARGET_AARCH64_APPLE_DARWIN_RUNNER

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
