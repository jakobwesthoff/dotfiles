# Copy/paste macro sections omit the declaration-order rule

**Skill**: cherri
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "Copy/paste macros"
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/common-patterns.md`, section "Morse/flash pattern with copy/paste macros"

**Current state**: Both sections show `copy name { ... }` followed by
`paste name` and discuss when to prefer pastables over functions, but
neither states that a `paste` must come after its `copy` declaration.

**Problem**: An agent structuring a file top-down (e.g. main logic first,
helpers at the bottom) will hit an avoidable compile error.

**Grounding**: cherrilang.org/language/copy-paste.html (fetched
2026-07-04): "For efficiency, you cannot use `paste` before declaring the
`copy` it's using." The same page also cautions against "long chains of
pastables pasting other pastables", which the skill likewise does not
mention.

**Proposed change**: In actions-and-includes.md's copy/paste section, add
the ordering rule (declare `copy` before any `paste` of it) and the
caution against chaining pastables inside pastables. One line each is
enough.
