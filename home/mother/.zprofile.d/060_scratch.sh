# Cargo's intermediate build artifacts (dependencies, incremental data)
# go to a tmpfs at /ram while a work session has one mounted, one
# directory per workspace, so builds do not write them to an SSD. Only
# the final binaries stay in each project's target/ on the system disk.
# kache's store stays on the NVMe at /scratch
# (setup/mother/setup.d/230-kache-scratch.sh), so it survives the
# tmpfs; from /ram, kache copies a hit into memory instead of sharing its
# blocks. Without the tmpfs the build output goes to /scratch, next to
# the store. A shell decides when it starts, so one started before the
# mount keeps /scratch.
if mountpoint -q /ram && [ -w /ram ]; then
    export CARGO_BUILD_BUILD_DIR="/ram/cargo-build/{workspace-path-hash}"
elif [ -d "/scratch/${USER}" ]; then
    export CARGO_BUILD_BUILD_DIR="/scratch/${USER}/cargo-build/{workspace-path-hash}"
fi
