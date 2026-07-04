# Installed compiler is three releases behind upstream; several skill claims are version-bound and already changed upstream

**Skill**: cherri
**Files**: affects `/Users/jakob/dotfiles/.claude/skills/cherri/SKILL.md` and all files under `/Users/jakob/dotfiles/.claude/skills/cherri/references/` (see list below)

**Current state**: The skill documents compiler behavior without naming any
compiler version. The installed binary (`/Users/jakob/.local/bin/cherri`)
reports `Cherri Compiler v2.1.0` and is built from a source checkout at
`/Users/jakob/Development/github/electrikmilk/cherri`, main @ `2ca7dfe`
(2026-01-24), which sits between the v2.1.0 and v2.1.1 tags.

**Problem**: Upstream has released three versions since:
v2.1.1 (2026-03-30), v2.2.0 (2026-04-29), v2.3.0 (2026-05-23) — dates from
`gh api repos/electrikmilk/cherri/releases`. The release notes change or
remove behavior the skill teaches. If the compiler is ever upgraded (or
the skill is used on another machine with a current compiler), this
guidance becomes wrong:

- **v2.1.1**: fixes "timerDuration type not found in actions/music"
  (PR #159) — the skill's "`#include 'actions/music'` may be broken" quirk
  is fixed upstream.
- **v2.2.0** (breaking): "@-prefix for variable references is now required
  and no longer deprecated" — invalidates the skill's "both bare name and
  @-prefixed form work" sections (SKILL.md "Variable referencing",
  language-fundamentals.md "Referencing variables").
- **v2.2.0**: "Scripting actions are automatically included if functions
  are used" — removes the hidden `actions/scripting` requirement for
  `function` (see companion todo).
- **v2.2.0**: "The compiler now figures out the right include you need ...
  we were blocking some includes based on a bad regex" — fixes the
  "include error messages may be misleading" quirk.
- **v2.2.0**: conditionals expanded to dates and quantities (PR #176);
  v2.1.1 already "allows using the expression result as a number in `if`
  comparisons" — weakens the skill's "action return values need explicit
  coercion for comparisons" quirk on newer versions.
- **v2.3.0** (breaking): "The Scripting actions category has been removed.
  Most of the actions were moved to basic and are now automatically
  included ... some were moved to device actions. Some actions were also
  moved from settings to device actions." — invalidates the skill's
  include table (`actions/scripting` entries in actions-and-includes.md,
  common-patterns.md, share-sheet-shortcut.md) and the "try
  `#include 'actions/scripting'` first as a fallback" advice.
- **v2.3.0** (breaking): `runJSAutomation()` argument order changed;
  rounding place names renamed (Ones Place → Integer, etc.).
- **v2.3.0**: `location()` accepts a text literal — relaxes the
  "`variable` typed params reject string literals" quirk for that action.

**Grounding**: `cherri -v` output; `git -C
/Users/jakob/Development/github/electrikmilk/cherri log -1` (commit
2ca7dfe, 2026-01-24) and `git tag -l` (newest local tag v2.1.0);
`gh api repos/electrikmilk/cherri/releases` release bodies quoted above
(retrieved 2026-07-04).

**Proposed change**: Decide and execute one of:
1. **Upgrade path** (preferred if nothing pins v2.1.0): update the local
   checkout/binary to v2.3.0, re-run the skill's examples against it, and
   rewrite the affected sections (include table, @-prefix rules, quirks
   that are fixed) for v2.3.0 behavior.
2. **Pin path**: keep v2.1.0 and add a prominent note in SKILL.md stating
   the skill targets Cherri v2.1.0 (commit 2ca7dfe) and that guidance is
   version-specific, listing the known upstream changes above so a future
   upgrade knows what to revisit.
Either way, add the compiler version the skill was validated against to
SKILL.md so future drift is detectable.
