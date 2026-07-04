# `set lazy` is stable since 1.48.0; skill still marks it unstable

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/settings.md` — Quick Reference table row `lazy` and section "Lazy Evaluation (unstable)"
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/invocation-primer.md` — "Unstable Features" section

**Current state**:
- settings.md table: "`lazy` | bool | `false` | Skip unused variable evaluation (unstable)".
- settings.md section heading: "## Lazy Evaluation (unstable)" with example starting `set unstable` / `set lazy`.
- invocation-primer.md: "Features like `lazy`, `which()`, `&&`/`||` operators require this" (i.e. unstable).

**Problem**: The unstable marker is outdated; the example teaches an unnecessary `set unstable` line, which conflicts with SKILL.md's own rule to never add `set unstable` preemptively.

**Grounding**:
- Changelog 1.47.0: "Add lazy evaluation setting" (#3083); 1.48.0: "Stabilize lazy evaluation" (#3180).
- Local test (just 1.55.0): justfile with only `set lazy` and a backtick variable that writes a marker file; running an unrelated recipe succeeded (exit 0) and the marker file was not created — lazy works without `set unstable` and skips unused variables.
- README settings table lists `lazy` (1.47.0) with no unstable marker.

**Proposed change**: Remove "(unstable)" from the table row and the section heading, remove `set unstable` from the lazy example, and drop `lazy` from invocation-primer.md's unstable-features list. Optionally tag the setting as 1.47.0+.

Related grounded facts that could be added in the same section:
- `export`ed variables are always evaluated even under `set lazy` (already in the skill, still correct).
- 1.47.1 added an `eager` keyword to force evaluation of unused assignments; it is currently unstable (changelog #3131, #3140). Include only with an unstable marker, or omit.
