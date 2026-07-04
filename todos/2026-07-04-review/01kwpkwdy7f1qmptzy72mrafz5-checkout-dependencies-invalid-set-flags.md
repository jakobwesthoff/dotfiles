# checkout_dependencies.sh: `set -uio pipefail` is invalid — no safety options are active

**Area**: shell-env
**File**: /Users/jakob/dotfiles/checkout_dependencies.sh:2

## Current state

```bash
#!/bin/bash
set -uio pipefail
```

## Problem

`-i` (interactive) is not a valid option for the `set` builtin in bash. The
call fails as a whole, so **none** of the intended options (`-u`, `-o
pipefail`) are applied, and an error is printed on every run. The intended
line was almost certainly `set -ueo pipefail` (the form used in
`bin/stage_for_storage.sh:2` and `bin/yabai_recording:3`). Note `-e` is also
missing compared to those scripts.

The script therefore runs with no unset-variable protection and no pipefail,
and continues past failed git clones/pulls.

## Grounding

```
$ bash -c 'set -uio pipefail; echo "after set: ok"; echo "u=$-"'
bash: line 1: set: -i: invalid option
set: usage: set [-abefhkmnptuvxBCEHPT] [-o option-name] [--] [-] [arg ...]
after set: ok
u=hBc          <- neither u nor pipefail is set
```

shellcheck additionally flags all four `pushd`/`popd` calls in this file with
SC2164 (use `|| exit` in case they fail) — moot once `set -e` is in place.

## Proposed change

Replace line 2 with `set -ueo pipefail`. Optionally add `|| exit` to the
`pushd` calls (or keep relying on `-e`).
