# basics.md gaps: failure/exit-code behavior, body comments echoed to the shell, parameter defaults referencing earlier parameters

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` (parameter item also fits the "Parameters" section)

**Current state**: basics.md documents the `-` sigil ("Continue on non-zero exit code") but never states the default failure behavior; body `#` comment handling is only implied by settings.md's `ignore-comments` row; parameter defaults are shown as literals or expressions over variables only.

**Problem / opportunity**: Three behaviors an author hits early, all currently unanswered by the skill:

1. **Default failure behavior**: a recipe stops at the first line returning non-zero, and just exits with that command's exit code.
   Grounding (just 1.55.0): recipe with `@echo before`, `@sh -c 'exit 7'`, `@echo after` printed only `before`, printed `error: recipe 'stops' failed on line 3 with exit code 7`, and `just` exited 7.

2. **Body comments are real recipe lines**: a `#` line inside a linewise recipe body is echoed (to stderr, like other command echoes) and passed to the shell unless `set ignore-comments` is active.
   Grounding (just 1.55.0): recipe body `# a body comment line` / `echo from-linewise` echoed both lines on stderr; stdout contained only `from-linewise`. settings.md already lists `ignore-comments`; basics.md never warns that comments in bodies are visible output.

3. **Parameter defaults can reference earlier parameters**:
   Grounding (just 1.55.0): `copy src dst=src:` invoked as `just copy onlyone` printed `src=onlyone dst=onlyone`.

**Proposed change**:
1. Add to the Recipes bullets: "A recipe stops at the first failing line; `just` exits with that command's exit code" (pairs naturally with the existing `-` sigil row).
2. Add one line to the Comments section: `#` lines inside recipe bodies are echoed and sent to the shell; use `set ignore-comments` (cross-link settings.md) or `@#`-free formatting if the echo is unwanted.
3. Add `copy src dst=src:` style example to the Parameters block showing defaults referencing earlier parameters.
