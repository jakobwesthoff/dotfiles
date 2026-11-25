# Test pacing for kache on Apple Silicon: test binaries started by
# `cargo test` run through kache, which holds them back until builds
# free their CPU slots. A runner set elsewhere wins.
if (( $+commands[kache] )); then
    [ -n "${CARGO_TARGET_AARCH64_APPLE_DARWIN_RUNNER-}" ] || CARGO_TARGET_AARCH64_APPLE_DARWIN_RUNNER='kache test-runner'
    export CARGO_TARGET_AARCH64_APPLE_DARWIN_RUNNER
fi
