# Failure defaults differ between shebang and `[script]` recipes and are unstated

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/advanced-patterns.md` — "Shebang Recipes" and "Script Recipes (`[script]`)" sections

**Current state**: The shebang section advises "Use `set -euxo pipefail`
in bash shebangs for safety" without saying what happens without it. The
script section notes the default interpreter is `sh -eu` without spelling
out the consequence. Neither section states how a failing command mid-body
propagates.

**Problem**: The two recipe styles have opposite failure defaults, and the
skill leaves both implicit:
1. A bash shebang without `-e` keeps executing after a failed command;
   `just` only sees (and reports) the script's overall exit status.
   Mid-body failures are silently skipped over.
2. A bare `[script]` recipe stops at the first failing command, because
   the default `script-interpreter` is `sh -eu`.

An author choosing between the two styles, or debugging a shebang recipe
that "ignores" errors, gets no help from the current text.

**Grounding** — local tests, just 1.55.0:

Shebang, no `-e`:
```just
sb:
  #!/usr/bin/env bash
  echo start
  false
  echo after-failure
  exit 9
```
`just sb` → stdout `start` then `after-failure` (execution continued past
`false`), stderr `` error: recipe `sb` failed with exit code 9 ``, exit 9.

Bare `[script]` (default `sh -eu`):
```just
[script]
scr:
  echo start
  false
  echo after-failure
```
`just scr` → stdout `start` only (stopped at `false`), stderr
`` error: recipe `scr` failed with exit code 1 ``, exit 1.

**Proposed change**:
1. Shebang section: add a bullet stating that without `-e` a failed
   command does not stop the script and `just` only reports the script's
   final exit status; this is the reason for the existing
   `set -euxo pipefail` advice.
2. Script section: add one line stating that the default `sh -eu`
   interpreter stops the recipe at the first failing command, and that
   replacing `script-interpreter` or using `[script("bash")]` without
   error flags loses that behavior.
