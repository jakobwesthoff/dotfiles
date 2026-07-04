# Frontmatter description lists the generic trigger "code review", colliding with the bundled `/code-review` skill

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, frontmatter

## Current state

```yaml
description: >-
  Review GitLab MRs with inline diff comments and suggestions via glab API.
  Use when asked to "review MR", "code review", or "add review comments".
```

## Problem / opportunity

Two of the three trigger phrases are platform-neutral: "code review" and
"add review comments" describe any review anywhere. Claude Code ships a
bundled `code-review` skill (reviews the current diff / PRs) and a built-in
`/review` for GitHub PRs, so on a non-GitLab project a request containing
"code review" matches this skill's stated triggers even though the skill
requires an authenticated `glab` and a GitLab MR. Conversely, the
description does not mention "merge request" spelled out, "GitLab review",
or "MR comments", which are phrases a user would actually say for the
GitLab case.

## Grounding

- Claude Code skills documentation (https://code.claude.com/docs/en/skills,
  fetched 2026-07-04):
  - `description`: "What the skill does and when to use it. Claude uses
    this to decide when to apply the skill."
  - Troubleshooting, "Skill triggers too often": "1. Make the description
    more specific."
  - Bundled skills: "Claude Code includes a set of bundled skills ...
    including `/code-review`, `/batch`, `/debug`, `/loop`, and
    `/claude-api`."
  - A separate `when_to_use` frontmatter field exists: "Additional context
    for when Claude should invoke the skill, such as trigger phrases or
    example requests. Appended to `description` in the skill listing"
    (combined text capped at 1,536 characters, key use case first).

## Proposed change

Make every trigger phrase GitLab-scoped and add the phrases users actually
say, for example:

```yaml
description: >-
  Review GitLab merge requests with inline diff comments and suggestions via
  the glab CLI and GitLab API. Use when asked to review an MR / merge
  request, post or add review comments on a GitLab MR, or do a code review
  on a GitLab-hosted repository.
```

Optionally move the trigger-phrase list into `when_to_use`. Do not list
bare "code review" as a trigger; GitHub PR reviews and working-tree diff
reviews are covered by other skills.
