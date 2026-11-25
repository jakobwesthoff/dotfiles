# Cargo's intermediate build artifacts (dependencies, incremental data)
# go to the NVMe at /scratch, one directory per workspace, next to
# kache's store there (setup/mother/setup.d/230-kache-scratch.sh). Only
# the final binaries stay in each project's target/ on the system disk.
# kache hands cached artifacts to a build without copying only when both
# sit on the same file system.
if [ -d "/scratch/${USER}" ]; then
    export CARGO_BUILD_BUILD_DIR="/scratch/${USER}/cargo-build/{workspace-path-hash}"
fi
