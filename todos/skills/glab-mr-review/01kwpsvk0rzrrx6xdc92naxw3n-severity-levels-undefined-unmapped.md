# Severity levels are never defined, and the analysis categories don't map to them

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, Critical rules ("Categorize findings in the summary: **Must address** / **Should address** / **Nit**")
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, step 3 (finding categories), step 6 (question format "[Severity] `file:line`"), step 9 (summary template)

## Current state

The skill uses two unconnected taxonomies:

- Step 3 tells the model what to look for, in four categories: "**Bugs**",
  "**Design concerns**", "**Test gaps**", "**Style/documentation**".
- Steps 6 and 9 and the Critical rules require a three-level severity
  (Must address / Should address / Nit) on every finding, question, and
  summary section.

No sentence defines the three severity levels or relates them to the four
analysis categories. The only hint is a quality guideline: "reviewers
reading summaries should immediately know what blocks merge vs. what's
optional" — which describes two levels, not three.

## Problem / opportunity

The approval-loop question format leads with "[Severity]" and the summary is
grouped by it, so severity assignment is a load-bearing step — yet it is
entirely left to the model's judgment call per invocation. Two runs on the
same MR can classify the same finding differently (a test gap as "Must
address" in one run, "Should address" in the next). An explicit definition
costs three lines and makes review output consistent across sessions.

## Grounding

All quotes read from the two skill files 2026-07-04. The gap is internal to
the skill; no external source applies.

## Proposed change

Define the three levels once, next to their first use (review-workflow.md,
before the summary template or in step 3), for example:

- **Must address**: correctness, security, or data-loss problems — merging
  as-is causes defects.
- **Should address**: design concerns and test gaps that ought to be fixed
  but don't make the change wrong.
- **Nit**: style, naming, documentation polish; optional.

State explicitly that the four step-3 categories are search lenses, not the
severity scale: severity is judged per finding (a "Bug" category finding is
usually Must address, but a hypothetical edge case may be Should address).
Exact definitions are a design decision — confirm the wording with the
user before editing the skill.
