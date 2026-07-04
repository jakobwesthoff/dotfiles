# bin/scf-format-stdin-php: stale hardcoded node path and unquoted trap

**Area**: shell-env
**File**: /Users/jakob/dotfiles/bin/scf-format-stdin-php

## Current state

```bash
#!/bin/bash

export PATH="/Users/jakob/.nvm/versions/node/v16.5.0/bin/:$PATH"

FORMAT_TMP_PATH="$(mktemp -t --suffix=.php scf-XXXXXXXXXX)"
trap "rm ${FORMAT_TMP_PATH}" EXIT

cat > "$FORMAT_TMP_PATH"

cd "$(dirname "${FORMAT_TMP_PATH}")"
/Users/jakob/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh format "$FORMAT_TMP_PATH"
```

## Problem

1. **Dead PATH entry**: `/Users/jakob/.nvm/versions/node/v16.5.0` does not
   exist on this machine (verified 2026-07-04; nvm now lives at
   `/opt/homebrew/opt/nvm` per `.zshrc.d/050_nvm.sh`, and `~/.nvm` has no
   v16.5.0). The prepended dir is silently ignored — if the docker-wrapper
   actually needed that node version, it would not get it.
2. **GNU mktemp dependency**: `--suffix` and this `-t TEMPLATE` form are GNU
   mktemp options; the script only works because coreutils' gnubin precedes
   `/usr/bin` in PATH. With stock BSD mktemp the call fails. Fine on this
   machine, but worth a comment or a portable invocation.
3. **shellcheck findings** (verified):
   - SC2064 (line 6): the trap string uses double quotes, expanding
     `${FORMAT_TMP_PATH}` at definition time. Works here because the variable
     is already set and never changes, but `trap 'rm "$FORMAT_TMP_PATH"' EXIT`
     is the robust form (also quotes the path inside the trap).
   - SC2164 (line 10): `cd` without `|| exit`.

   The referenced `docker-wrapper.sh` itself exists
   (`~/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh`).

## Proposed change

- Remove (or update) the stale nvm PATH export — decide whether the wrapper
  still needs a pinned node at all.
- `trap 'rm -f "$FORMAT_TMP_PATH"' EXIT` and `cd ... || exit 1`.
- Optionally make the tempfile creation portable across BSD/GNU mktemp by
  creating a temp directory instead (both support `mktemp -d`):
  `tmpdir="$(mktemp -d)"; FORMAT_TMP_PATH="$tmpdir/input.php"` with
  `trap 'rm -rf "$tmpdir"' EXIT`.
