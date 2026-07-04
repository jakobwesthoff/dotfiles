# Context-line comments require both `old_line` and `new_line`; skill marks `old_line` optional and never teaches computing it

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, sections "Computing Line Numbers" and "Which line field to use"
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, step 7 (`pos()` helper)

## Current state

The "Which line field to use" table says:

> | Context (unchanged) | Yes | Yes (optional) |

The line-counting procedure only describes the new-file counter:

> Count forward from the new-file start (`315`) for each line in the hunk.
> Context lines (no `+`/`-` prefix) and added lines (`+` prefix) both
> increment the new-file counter. Removed lines (`-` prefix) do NOT
> increment it.

The `pos()` payload helper in review-workflow.md hardcodes `new_line` only
and has no way to express `old_line`.

## Problem / opportunity

Per GitLab's documentation, a thread on an unchanged line needs BOTH fields,
so "optional" is wrong. Worse, `old_line` on a context line is generally NOT
equal to `new_line` (they diverge as soon as earlier lines in the file were
added or removed), and the skill gives no procedure for computing the
old-file line number at all. A reviewer commenting on a context line (a
common case, e.g. "this unchanged call is now wrong given the change above")
either omits `old_line` (invalid per docs) or guesses it.

The same gap applies to removed lines: the table says to set `old_line`, but
no counting rule for the old-file counter is given.

## Grounding

GitLab Discussions API, "Create new merge request thread"
(https://docs.gitlab.com/api/discussions/, fetched 2026-07-04):

- "To create a thread on an unchanged line, include both `position[new_line]`
  and `position[old_line]`", with the caveat that these line numbers may
  differ if earlier changes affected positioning.
- Added lines: "use `position[new_line]` and don't include
  `position[old_line]`."
- Removed lines: "use `position[old_line]` and don't include
  `position[new_line]`."
- Parameter table: `position[new_line]` = "For `text` diff notes, the line
  number after change"; `position[old_line]` = "For `text` diff notes, the
  line number before change".

Old-file counting rule follows from unified diff format: the hunk header
`@@ -309,6 +315,10 @@` gives the old-file start (309); context lines and
removed (`-`) lines increment the old-file counter, added (`+`) lines do not.

## Proposed change

1. Fix the table: Context (unchanged) -> `new_line` Yes, `old_line` Yes
   (required, and usually different from `new_line`).
2. Extend "Computing Line Numbers" with the old-file counter: start at the
   old start from the hunk header; context and removed lines increment it;
   added lines do not. State explicitly that for context lines both counters
   must be tracked and both values sent.
3. Extend the `pos()` helper in review-workflow.md with an optional
   `old_line` parameter so context-line and removed-line comments are
   expressible.
