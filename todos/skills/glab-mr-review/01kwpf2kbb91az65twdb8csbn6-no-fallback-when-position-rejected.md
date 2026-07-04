# No fallback documented when a positioned comment POST fails

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, step 8, and `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`

## Current state

Step 8 says only "Verify each returns a `discussion.id` in the response."
Nothing tells the model what to do when a positioned POST fails, even though
the skill's own anti-pattern section acknowledges positioned posts can fail.

## Problem / opportunity

Positioned discussion creation has documented failure modes (see grounding).
Without a fallback rule, a failing comment either gets silently dropped
(losing the finding) or the model retries blindly with the same payload.

## Grounding

- Failure modes: GitLab Discussions API docs point to issue
  gitlab-org/gitlab#296829 for incorrect SHA parameters; that issue (fetched
  2026-07-04) documents 500 Internal Server Error ("Failed to find diff line
  for: <file>, old_line: N, new_line: N",
  `DiffNote::NoteDiffFileCreationError`) and comments rendering as download
  links instead of inline threads. The REST troubleshooting page
  (https://docs.gitlab.com/api/rest/troubleshooting/, fetched 2026-07-04)
  describes 400 as "A required attribute of the API request is missing" /
  attribute validation failures.
- Fallback mechanism exists: the same Discussions endpoint accepts a
  position-less payload — "Create a new thread on the overview page" with
  only `body` (https://docs.gitlab.com/api/discussions/, fetched
  2026-07-04).
- Constraint on the fallback: suggestion blocks are only applicable inside
  diff threads (https://docs.gitlab.com/user/project/merge_requests/reviews/suggestions/,
  fetched 2026-07-04), so a comment demoted to a plain thread must have its
  ```suggestion block converted to a normal fenced code block.

## Proposed change

Add an error-handling rule to the posting step:

1. On failure, first re-verify the computed `old_line`/`new_line` against
   the hunk headers and re-fetch `diff_refs` (the MR may have been updated
   since step 2), then retry once.
2. If the positioned POST still fails, post the finding as a plain
   (position-less) discussion whose body starts with the `file:line`
   reference, converting any suggestion block into a regular code block.
3. Report in the final output which comments were posted inline and which
   were demoted to plain threads.
