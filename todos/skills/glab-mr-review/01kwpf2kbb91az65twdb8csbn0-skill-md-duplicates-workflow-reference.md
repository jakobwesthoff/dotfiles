# SKILL.md duplicates most of review-workflow.md instead of acting as an overview; the copies have already drifted

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, section "Workflow" (steps 1-7)
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md` (steps 1-9)

## Current state

SKILL.md's Workflow section restates nearly everything review-workflow.md
contains: the same `glab mr view` / `glab mr diff` commands, the same
`glab api .../merge_requests/<IID>` SHA extraction, the same
post-directly-vs-preview AskUserQuestion, the same approval loop, the same
Python `json.dump()` payload rule, the same POST commands for discussions
and notes, and the same only-approved-comments summary constraint. The
reference file adds only the severity checklist, the question format, the
Python script skeleton, the summary markdown template, quality guidelines,
and anti-patterns.

The copies have drifted already:

- Step numbering differs (approval loop is step 5 in SKILL.md, step 6 in
  review-workflow.md; payload generation is 6 vs 7; posting is 7 vs 8/9).
- The approval-loop option sets differ (see the separate todo on
  AskUserQuestion options).
- SKILL.md step 7 posts `--input /tmp/comment.json`; review-workflow.md
  step 8 posts `--input /tmp/mr-review-comment-1.json`.

## Problem / opportunity

Since SKILL.md always instructs reading review-workflow.md for "the detailed
loop mechanics", both copies end up in context, and every duplicated line is
paid twice. Two normative copies of the same procedure also mean future
edits land in one file and not the other, worsening the drift above; when
the copies disagree, the model has no rule for which one wins.

## Grounding

- Anthropic skill best practices
  (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices,
  fetched 2026-07-04): "SKILL.md serves as an overview that points Claude to
  detailed materials as needed, like a table of contents in an onboarding
  guide." Checklist item: "Progressive disclosure used appropriately."
  Also: "For reference files longer than 100 lines, include a table of
  contents at the top." (gitlab-api-comments.md is 191 lines,
  review-workflow.md 184 lines; neither has a TOC.)
- Claude Code skills docs (https://code.claude.com/docs/en/skills, fetched
  2026-07-04): "Keep the body itself concise. Once a skill loads, its
  content stays in context across turns, so every line is a recurring token
  cost."
- Drift evidence: the three divergences quoted above, from the current file
  contents (read 2026-07-04).

## Proposed change

Pick one canonical home for the step-by-step procedure:

- Option A (recommended given SKILL.md is only 107 lines): keep the full
  operational workflow in SKILL.md and cut review-workflow.md down to the
  material SKILL.md lacks (finding categories, question format, Python
  script skeleton, summary template, quality guidelines, anti-patterns),
  renaming it accordingly.
- Option B: shrink SKILL.md's workflow to one-line step summaries with
  pointers and let review-workflow.md own all commands.

Either way, remove the duplicated command blocks from one file, align step
numbering, and add a short table of contents to both reference files.
