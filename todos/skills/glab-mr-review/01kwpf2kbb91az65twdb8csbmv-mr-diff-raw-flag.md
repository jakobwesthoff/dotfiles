# Use `glab mr diff --raw` for machine-parseable diffs when computing line numbers

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md` step 1 and `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md` step 1

## Current state

Both files show only:

```bash
glab mr diff <IID> --repo <group/project>
```

The line-number computation in step 3/4 depends on parsing this output's
hunk headers exactly.

## Problem / opportunity

The default output is the human-oriented rendering with `--color` defaulting
to `auto`. Since the whole downstream workflow (counting lines from `@@`
hunk headers) treats this output as machine input, the skill should request
the raw format explicitly instead of relying on color auto-detection and the
pretty renderer.

## Grounding

`glab mr diff --help` (glab 1.105.0, local, 2026-07-04):

- `--raw    Use raw diff format that can be piped to commands.`
- `--color  Use color in diff output: always, never, auto. (auto)`
- Help intro: "Use `--color=never` to disable color output."

## Proposed change

Change the command in both files to:

```bash
glab mr diff <IID> --repo <group/project> --raw
```

and note that `--raw` exists specifically to produce pipe-friendly raw diff
output for the line-counting step.
