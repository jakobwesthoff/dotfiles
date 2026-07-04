# attributes.md is missing `[exit-message]`, `[android]`, `[shell]`, `[continue]`, and `[cache]`

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/attributes.md` — "Complete Reference" tables

**Current state**: The reference presents itself as complete ("All recipe and module attributes") but lacks five attributes that exist on just 1.55.0.

**Problem**: Authors relying on the "complete" table will not find these; `[continue]` in particular is easy to misguess (it is about signals, not error handling).

**Grounding**:
- `[exit-message]` (1.39.0, changelog #2568; README table: "Print error message if recipe fails regardless of `set no-exit-message`"). Parsed and ran locally on 1.55.0.
- `[android]` (1.50.0, changelog #2884) — platform attribute missing from the skill's Platform Targeting table. Parsed locally.
- `[shell]` (1.52.0, changelog #3359; README table: "Execute recipe as a shell recipe, overriding `set default-script`"). Takes no arguments — local test `[shell('bash', '-c')]` failed with `error: attribute 'shell' got 2 arguments but takes 0 arguments`, confirming it is a bare flag, not a per-recipe shell override.
- `[continue(SIGNALS)]` (1.54.0, changelog #3442; README table: "Continue execution normally if a command is interrupted by any of `SIGNALS` and exits successfully. Defaults to `SIGINT`."). Signal handling only — local test confirmed a recipe line exiting 3 under `[continue]` still fails the recipe (exit 3), so it must NOT be documented as continue-on-error.
- `[cache]` (1.54.0, changelog #3437; README: "may only be used with script recipes and is currently unstable", supports `[cache(inputs = …, outputs = …, extra = …)]`, cache stored in `.justcache` next to the justfile). Local tests: `[cache]` on a linewise recipe → `error: shell recipe 'slow' has script recipe attribute 'cache'`; on a `[script]` recipe → `error: cached recipes are currently unstable …`.

**Proposed change**: Add all five to the appropriate tables:
- `[exit-message]` under Execution Control next to `[no-exit-message]`.
- `[android]` in the Platform Targeting table.
- `[shell]` under Execution Control with the `default-script` cross-reference.
- `[continue]`/`[continue("SIGHUP", …)]` under Execution Control, described strictly as signal tolerance (command interrupted by the signal but exiting successfully), defaulting to SIGINT.
- `[cache]` with an explicit "unstable, script recipes only" marker (consistent with the skill's set-unstable policy), or omit it deliberately with a note that recipe caching exists but is unstable as of 1.55.0.
