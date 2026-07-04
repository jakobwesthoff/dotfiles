# `&&`/`||` operators and `which()` now require `set lists`, not plain `set unstable`

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/variables-and-expressions.md` — "Operators" table
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/functions.md` — "Executables" section
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/invocation-primer.md` — "Unstable Features" section
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/settings.md` — Quick Reference table (missing `lists` row)

**Current state**:
- variables-and-expressions.md operators table: "`&&` | Logical AND on strings (unstable)" and "`||` | Logical OR on strings (unstable)".
- functions.md: "`which()` requires `set unstable`."
- invocation-primer.md: "Features like `lazy`, `which()`, `&&`/`||` operators require this" (referring to `--unstable`/`set unstable`).
- settings.md has no `lists` setting.

**Problem**: On just 1.55.0 these features are gated behind the new `set lists` setting (which itself is unstable and additionally requires `set unstable`). `set unstable` alone is no longer sufficient, so the skill's guidance produces justfiles that fail with a misleading fix.

**Grounding**:
- Local test (just 1.55.0): `a := '' || 'b'` without any settings → `error: logical operators require 'set lists'`. Same justfile with `set unstable` (no `set lists`) → identical error. With `set lists` but without `set unstable` → `error: the 'lists' setting is currently unstable, invoke 'just' with '--unstable' ...`.
- Local test: `w := which('ls')` → `error: the 'which()' function requires 'set lists'`.
- Changelog: `set lists` added in 1.53.0 (casey/just#3372); "Make `which()` require `set lists`" in 1.53.0 (#3418); `&&`/`||` originally added in 1.37.0 (#2444).
- README settings table: "`lists` (1.53.0) | boolean | false | Values may be lists of strings instead of strings. Currently unstable."
- `set lists` is an umbrella for a list data type: list literals, `split()`, `show()`, `bool()`, negation operator `!`, mapping dependencies over lists, `+`/`/` on lists (all 1.53.0, changelog "Lists" section).

**Proposed change**:
1. In variables-and-expressions.md, change the `&&`/`||` rows to state they require `set lists` (unstable, 1.53.0, which in turn requires `set unstable`).
2. In functions.md, change the `which()` note from "requires `set unstable`" to "requires `set lists`".
3. In invocation-primer.md, drop `which()` and `&&`/`||` from the plain-unstable list (see also the separate todo on `lazy`), or rephrase to name `set lists`.
4. Add a `lists` row to the settings.md Quick Reference table, marked unstable, with a one-line description of the list type it enables.
