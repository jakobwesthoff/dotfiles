# Two passes filed the same glab-mr-review trigger finding with contradictory assessments — reconcile before fixing

**Area**: audit-meta
**Files**:
- /Users/jakob/dotfiles/todos/2026-07-04-review/01kwppd9ezp2ebng09dbfrgfqj-glab-mr-review-trigger-overlap.md (claude-config pass)
- /Users/jakob/dotfiles/todos/skills/glab-mr-review/01kwpf2kbb91az65twdb8csbmx-description-trigger-overlap.md (skill-content pass)

## Current state

Both todos target the same line — the `description` frontmatter of
`.claude/skills/glab-mr-review/SKILL.md` — and both flag the "code
review" trigger phrase as colliding with the built-in `code-review`
skill. They disagree on the rest:

- The claude-config todo states: "The other two listed triggers
  ('review MR', 'add review comments') are unambiguous." Its proposed
  description keeps `"add review comments"` as-is.
- The skills todo states: "Two of the three trigger phrases are
  platform-neutral: 'code review' and 'add review comments'". Its
  proposed description GitLab-scopes every phrase ("post or add review
  comments on a GitLab MR") and additionally suggests moving triggers
  into a `when_to_use` frontmatter field.

## Problem

Whoever picks up either todo alone applies a fix the other todo calls
insufficient or already-done. The proposed replacement descriptions are
different texts for the same line, so the second todo executed would
overwrite the first.

## Grounding

- Both todo files read in full on 2026-07-04; quotes above are
  verbatim.

## Proposed change

Treat the skills-pass todo (01kwpf2kbb91az65twdb8csbmx) as the
authoritative one: it addresses the superset of phrases and cites the
skills documentation for `when_to_use`. Fold the one element unique to
the claude-config todo (the observation that the built-in `review`
skill covers GitHub PRs) into it if desired, and delete or stub the
claude-config todo (01kwppd9ezp2ebng09dbfrgfqj) with a pointer so the
edit happens once.
