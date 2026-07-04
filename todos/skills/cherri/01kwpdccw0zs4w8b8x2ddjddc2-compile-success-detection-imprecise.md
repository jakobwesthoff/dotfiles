# "Silent output = success" is imprecise; lookup commands exit non-zero on success

**Skill**: cherri
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/cherri/SKILL.md`, section "Invoking the compiler"
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/patterns-and-practices.md`, section "CLI hygiene"

**Current state**: SKILL.md says:

> Silent output = success. Errors print to stdout.

patterns-and-practices.md says:

> Silent output (no stdout, exit code 0) means compilation succeeded.
> Error messages appear on stdout when compilation fails.

Neither file mentions exit-code behavior of the lookup flags.

**Problem**:
1. A successful compile is not necessarily silent: warnings (e.g. the
   bare-variable-reference deprecation warning) print to stdout while the
   compile still succeeds with exit code 0 and produces the `.shortcut`
   file. An agent applying "silent output = success" strictly will
   misclassify a warning-bearing success as a failure.
2. `cherri --action=...` prints its documentation to stdout but exits with
   code 1 even when the action is found. An agent (or scripting) that
   treats non-zero exit as failure will misread every successful action
   lookup. `--docs=<category>` exits 0.

**Grounding** (local verification, Cherri Compiler v2.1.0, 2026-07-04):

- Compiling a file containing `@myVar = "hello"` / `alert(myVar, "Title")`
  prints `Warning: Deprecated: Prefix variable reference 'myVar' with @ for
  compilation speed and readability. (1:12)` to stdout, exits 0, and writes
  `<name>_unsigned.shortcut`.
- Failed compile (broken include) prints the error to stdout (verified via
  `2>/dev/null` still showing full output) and exits 1.
- `cherri --action=jsonRequest --no-ansi 2>/dev/null; echo "rc=$?"` prints
  the full doc block (stdout) and then `rc=1` despite the lookup
  succeeding.
- `cherri --docs=photos --no-ansi` exits 0.

**Proposed change**: Replace the success rule in both files with:
"Compilation success = exit code 0 AND a `.shortcut` file written.
Warnings may print on success; errors print to stdout and exit 1
(compiler panics exit 2). `--action` lookups exit 1 even when the action
is found — judge lookup success by the output, not the exit code."
