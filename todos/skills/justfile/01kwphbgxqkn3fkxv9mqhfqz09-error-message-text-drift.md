# Quoted error messages drifted: just lowercased all error messages in 1.51.0

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — Anti-Patterns: "just reports `error: Recipe line has extra leading whitespace`"
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/attributes.md` — intro: "Placing a `#` comment after an attribute causes an `Extraneous attribute` error."

**Current state**: Both quoted messages use capitalized wording.

**Problem**: Cosmetic but the skill quotes them as exact strings; an agent grepping output for the capitalized text will not match.

**Grounding** (local just 1.55.0):
- Extra indentation: `error: recipe line has extra leading whitespace` (lowercase r).
- Comment after attribute: `error: extraneous attribute` (lowercase e).
- Changelog 1.51.0: "Make error messages lowercase" (#3314), "Remove periods from error messages" (#3316).

**Proposed change**: Update both quotes to the lowercase forms, or hedge with "reports an `extra leading whitespace` error" so the text stays version-proof.
