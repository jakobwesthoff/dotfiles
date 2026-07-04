# `glab-mr-review` claims the trigger phrase "code review", colliding with Claude Code's built-in code-review skill

**Area**: claude-config (cross-skill trigger consistency)
**File**: /Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md lines 1-6 (frontmatter)

## Current state

```
description: >-
  Review GitLab MRs with inline diff comments and suggestions via glab API.
  Use when asked to "review MR", "code review", or "add review comments".
```

## Problem

Claude Code v2.1.201 ships a built-in `code-review` skill ("Review the
current diff for correctness bugs and reuse/simplification/efficiency
cleanups...") and a built-in `review` skill ("Review a GitHub pull
request..."), both present in the session skill list alongside
`glab-mr-review`. The phrase "code review" is claimed by the local
skill's description and by the built-in skill's name and purpose. A
user saying "code review" on a non-GitLab project can plausibly route
to the GitLab MR workflow, and on a GitLab project the built-in may win
instead. The other two listed triggers ("review MR", "add review
comments") are unambiguous.

This is a description-level trigger conflict across the skill set; the
skill's body content is covered by its own review under
`todos/skills/glab-mr-review/`.

## Grounding

- Frontmatter quoted above (`head -8 .claude/skills/glab-mr-review/SKILL.md`,
  2026-07-04).
- Session skill list of 2026-07-04 (v2.1.201) showing `code-review`,
  `review`, and `glab-mr-review` side by side with the descriptions
  quoted above.

## Proposed change

Drop `"code review"` from the trigger list and anchor the description
to GitLab, e.g.: `Use when asked to "review MR", "review this merge
request", or "add review comments" on a GitLab project.` This keeps the
built-in `/code-review` unambiguous for working-diff reviews.
