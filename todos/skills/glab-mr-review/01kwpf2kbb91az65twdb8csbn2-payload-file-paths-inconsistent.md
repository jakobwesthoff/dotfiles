# Payload file paths are inconsistent: SKILL.md posts a single `/tmp/comment.json` "in parallel", reference uses numbered files

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, step 7 ("Post approved comments (parallel) and summary note")
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, steps 7-8

## Current state

SKILL.md step 7 is titled "Post approved comments (parallel)" but its
example uses one fixed filename for all comments:

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/discussions" \
  --method POST --input /tmp/comment.json -H 'Content-Type: application/json'
```

review-workflow.md step 7 writes numbered files
(`/tmp/mr-review-comment-{i+1}.json`) and step 8 posts
`/tmp/mr-review-comment-1.json`. gitlab-api-comments.md also uses the
single `/tmp/comment.json` in its posting example.

## Problem / opportunity

- Posting several comments "in parallel" from one shared filename cannot
  work; each parallel call needs its own payload file. A model following
  SKILL.md literally would overwrite the payload between posts or post the
  same comment repeatedly.
- All paths are hardcoded to `/tmp`. Claude Code agent sessions carry an
  explicit instruction to use the session-specific scratchpad directory
  instead of `/tmp` (present in this session's system prompt: "Always use
  this scratchpad directory for temporary files instead of `/tmp`"), so the
  skill's instruction conflicts with harness guidance. Fixed well-known
  paths like `/tmp/comment.json` are also shared between concurrent
  sessions on the same machine.

## Grounding

- The three quoted snippets come from the current skill files (read
  2026-07-04); the parallel-posting claim and the single filename are in the
  same SKILL.md step.
- The scratchpad instruction is quoted from the Claude Code agent system
  prompt observed in this session (2026-07-04).

## Proposed change

- Use the numbered-file scheme everywhere (`mr-review-comment-<n>.json`),
  and make SKILL.md's example show a numbered file so the "(parallel)"
  claim is executable.
- Replace hardcoded `/tmp/` with "a session temp directory (e.g. the
  scratchpad directory if the harness provides one)" or generate the
  directory with `mktemp -d`.
