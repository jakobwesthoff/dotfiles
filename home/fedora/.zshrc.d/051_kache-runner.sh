# Test pacing for kache on x86_64 Linux: test binaries started by
# `cargo test` run through kache, which holds them back until builds
# free their CPU slots. A runner set elsewhere wins.
if (( $+commands[kache] )); then
    [ -n "${CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER-}" ] || CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER='kache test-runner'
    export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER
fi
