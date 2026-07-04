# `!~` (regex mismatch) operator exists since 1.39.0; skill claims only `==`, `!=`, `=~` are supported

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/conditionals-and-flow.md` — "Comparison Operators" table and Anti-Patterns section

**Current state**:
- Operator table lists only `==`, `!=`, `=~`.
- Anti-pattern: "NEVER use `>`, `<`, `>=`, or `<=` for comparisons — just only supports `==`, `!=`, and `=~`."

**Problem**: The "only supports" claim is factually wrong and omits a useful operator, forcing awkward `if x =~ p { … } else { … }` inversions.

**Grounding**:
- Local test (just 1.55.0): `neg := if 'abc' !~ 'z' { 'no-match-op-works' } else { 'x' }`; `just --evaluate neg` printed `no-match-op-works` (exit 0, no unstable required).
- Changelog 1.39.0: "Add regex mismatch conditional operator" (#2490).

**Proposed change**: Add a `!~` row ("Regex non-match", 1.39.0) to the operator table and correct the anti-pattern sentence to "just only supports `==`, `!=`, `=~`, and `!~`".
