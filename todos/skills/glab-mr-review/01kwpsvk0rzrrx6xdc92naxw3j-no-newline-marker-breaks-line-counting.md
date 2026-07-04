# Line-counting rule miscounts `\ No newline at end of file` markers as context lines

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, section "Computing Line Numbers"

## Current state

> Count forward from the new-file start (`315`) for each line in the hunk.
> Context lines (no `+`/`-` prefix) and added lines (`+` prefix) both increment
> the new-file counter. Removed lines (`-` prefix) do NOT increment it.

## Problem / opportunity

Unified diffs contain a fourth line kind: the no-trailing-newline marker,
which starts with `\` and represents no file line at all. It has "no `+`/`-`
prefix", so the stated rule classifies it as a context line and increments
the counter, producing positions that are off by one for every marker seen.
The marker appears whenever the old or new version of a file lacks a final
newline, and can occur mid-hunk (after the old file's last line) as well as
at the end.

## Grounding

Reproduced locally (2026-07-04) in a scratch git repo: file with three lines
and no trailing newline, edited to four lines still without trailing
newline. `git diff` output:

```
@@ -1,3 +1,4 @@
 line1
-line2
-line3
\ No newline at end of file
+line2 changed
+line3
+line4
\ No newline at end of file
```

Both `\ No newline at end of file` lines sit inside the hunk; counting them
as context lines yields `new_line` values shifted past the real lines.
`glab mr diff` reproduces the underlying git diff (its `--raw` flag exists
"to be piped to commands", `glab mr diff --help`, glab 1.105.0), so the
marker reaches the skill's counting step unchanged.

## Proposed change

Add one rule to "Computing Line Numbers": lines beginning with `\`
(`\ No newline at end of file`) are metadata, not file lines — they
increment neither counter. Equivalent guard for the old-file counter once
that is documented (see the context-line todo).
