# `assert()` message is optional since 1.53.0; skill presents the two-argument form as the only signature

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/conditionals-and-flow.md` — "`assert(condition, message)`" section
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/functions.md` — (assert is not listed in functions.md at all; only `error()` appears under "Error & Flow Control")

**Current state**: conditionals-and-flow.md documents only `assert(condition, message)`. functions.md's "Error & Flow Control" section documents `error(message)` but not `assert()`.

**Problem**: Minor gap: the one-argument form now works, and assert is absent from the file that claims to list all built-in functions.

**Grounding**:
- Local test (just 1.55.0): `ok := assert('a' == 'a')` evaluated without error to `""` (no `set lists`/`set unstable` needed).
- Changelog 1.53.0: "Allow omitting `assert()` message" (#3423).
- Related 1.53.0 lists-gated behavior (do NOT document as default): with `set lists` enabled, `assert()` evaluates to `"true"` (#3404) / `assert(condition)` evaluates to condition (#3405). Without lists, the local test above shows it still returns the empty string.

**Proposed change**: Note in conditionals-and-flow.md that the message argument is optional since 1.53.0, and add an `assert()` row next to `error()` in functions.md's Error & Flow Control section (return value: empty string on success, as already documented).
