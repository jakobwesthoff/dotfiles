# Posting-mode question offers no "report only" path and is decided before the user sees any findings

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, step 4 and Critical rules ("ALWAYS ask post-directly vs. preview")
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, step 5

## Current state

SKILL.md step 4:

> Before posting anything, use AskUserQuestion:
>
> - **Post directly** — generate payloads and post all comments + summary at once
> - **Preview first** — enter the interactive approval loop (step 5)

review-workflow.md step 5 offers the same two options. Both routes end in
posting to the MR; the question text carries no information about what was
found.

## Problem / opportunity

Two workflow-design gaps:

1. **Every path writes to GitLab.** A user who wants the review itself
   (read the findings in chat, maybe fix locally) has no offered option;
   the closest workaround is choosing "Preview first" and then skipping
   every comment one by one. "Review this MR" does not imply consent to
   post — the skill's own "When to use" separates "review a GitLab merge
   request" from "add inline code review comments".
2. **The choice is uninformed.** The question is asked after analysis
   (step 3 precedes step 4), so finding counts and severities are already
   known, but the skill does not say to include them. Choosing between
   "post 2 nits directly" and "preview 14 findings including 3 blockers"
   is a different decision; the user currently makes it blind.

## Grounding

- Both quoted sections read from the skill files 2026-07-04; step order
  (analysis in step 3/4, mode question in step 4/5) per the same files.
- A third option fits the tool: AskUserQuestion questions take "2-4
  choices, each with `label` and `description`"
  (https://code.claude.com/docs/en/agent-sdk/user-input, fetched
  2026-07-04), so Post directly / Preview first / Report only is within
  the limit.

## Proposed change

1. Add a third option to the mode question in both files: **Report only** —
   present the findings in the conversation, post nothing to GitLab.
2. Require the question's description to summarize the analysis result
   before asking, e.g. "Found N findings: X must address, Y should
   address, Z nits" (severity labels per the existing summary taxonomy).
3. Update the Critical rules bullet accordingly ("ask post-directly vs.
   preview vs. report-only").
