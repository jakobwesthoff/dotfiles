# Missing pitfall: without `set guards`, `?` sigils are silently passed to the shell as command text

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/conditionals-and-flow.md` — "Guards (`?` sigil)" section
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — "Line Sigils" table

**Current state**: Both files say the `?` sigil "requires `set guards`", but neither says what happens when the setting is absent.

**Problem**: The failure mode is silent and confusing: just does not error; the `?` becomes part of the command. A `?test -f x` line then fails with a shell "command not found" error instead of behaving as a guard, and an LLM (or user) may misdiagnose it.

**Grounding**:
- Local test (just 1.55.0), recipe without `set guards`:
  ```
  noguards:
    ?test -f /nonexistent
    @echo after
  ```
  Output: line echoed as `?test -f /nonexistent`, then `sh: ?test: command not found`, `error: recipe 'noguards' failed on line … with exit code 127`.
- README "Sigils" section: "If the `guards` setting is unset or false, `?` sigils are ignored and instead treated as part of the command."
- Version tag: guard sigil and `guards` setting added in 1.47.0 (changelog #2547; README settings table `guards` 1.47.0). The skill presents guards unconditionally with no version tag.

**Proposed change**: In the guards section, add: forgetting `set guards` does not produce a just error — the `?` is passed to the shell as part of the command (typically `command not found`, exit 127). Tag the feature 1.47.0+. Optionally note the verified reserved-exit-code behavior: a guard command exiting with a code other than 0 or 1 fails with `error: guard line in recipe '…' returned reserved exit code N` (verified locally with exit 2).
