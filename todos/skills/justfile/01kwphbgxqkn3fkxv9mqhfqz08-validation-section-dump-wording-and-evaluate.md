# SKILL.md validation: "Silent --dump output" wording is misleading; add `--evaluate` to close the variable-evaluation gap

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/SKILL.md` — "Validating justfiles" section

**Current state**:
> Silent `--dump` output to stdout = valid parse. Errors print to stderr.
> Note: `--dump` only checks syntax — it does not evaluate variables, so `error()` and `assert()` at variable level are NOT triggered.

**Problem**:
1. The first sentence is contradictory as written: `--dump` is not silent on success — it prints the full formatted justfile to stdout. An LLM reading "silent output = valid" may conclude that printed output indicates a problem.
2. The section names the variable-evaluation blind spot but offers no command that closes it, even though one exists.

**Grounding** (local just 1.55.0):
- `just -f <file> --dump` on a justfile containing `x := error("boom-at-eval")` succeeded (exit 0) and printed the formatted justfile to stdout — confirms both that dump output is not silent and that variable-level `error()` is not triggered.
- `just -f <file> --evaluate` on the same justfile failed: `error: call to function 'error' failed: boom-at-eval` (exit 1) — `--evaluate` closes the gap.
- Caveat verified: `--evaluate` executes backtick expressions. A justfile with ``marker := `echo side-effect > eval-marker.txt; echo done` `` created `eval-marker.txt` during `just --evaluate marker`. So `--evaluate` is not side-effect-free and must not be run blindly on justfiles with mutating backticks.
- Also verified: running ANY recipe evaluates all top-level variables in that module (the `error()` variable aborted `just ok` even though `ok` does not use `x`), unless `set lazy` is active.

**Proposed change**:
1. Reword to: "`--dump` prints the formatted justfile to stdout and exits 0 on a valid parse; parse errors go to stderr with a non-zero exit."
2. Add `just --justfile /path/to/justfile --evaluate` to the validation command list, with two notes: it triggers variable-level `error()`/`assert()`, and it executes backticks/`shell()` calls, so inspect the justfile for side-effecting backticks first.
