# `[private]` works on modules (1.47.0) and variables; the applicability table says it does not

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/attributes.md` — "Applicability" table; also `/Users/jakob/dotfiles/.claude/skills/justfile/references/variables-and-expressions.md` (no mention of private variables)

**Current state**: The applicability table row reads "`[private]` | Recipe: yes | Module: no | Alias: yes". Private variables are not mentioned anywhere in the skill.

**Problem**: Two capabilities are missing/denied:
1. `[private]` on a `mod` statement hides the module from `--list`.
2. `[private]` on a variable assignment hides it from `--evaluate`/`--variables`.

**Grounding**:
- Local test (just 1.55.0): `[private]` directly above `mod sub` parsed (exit 0) and `just --list` showed only the root recipe, no `sub ...` entry. Without the attribute the module is listed.
- Changelog 1.47.0: "`[private]` modules are excluded from `--list` output" (#2889).
- Local test (just 1.55.0): `[private]` above `secret := 'hidden-var'` hides it — `just --evaluate` printed only the other variable.
- README attributes table: "`[private]` (1.10.0) | alias, recipe | Make recipe, alias, or variable private."
- Underscore-prefix naming also hides modules/variables the same way it hides recipes (README "Private Recipes" section documents `[private]` as the no-rename alternative).

**Proposed change**:
1. Change the applicability row for `[private]` to yes for Module (1.47.0+) and add a Variable column or footnote for private variables.
2. In variables-and-expressions.md, add one line: variables can be hidden from `--evaluate`/`--variables` with `[private]` above the assignment or an `_` name prefix.
