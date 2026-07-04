# SKILL.md and review-workflow.md define different AskUserQuestion option sets for the approval loop

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, step 5
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, step 6

## Current state

SKILL.md step 5 lists three options:

> - **Post this comment** — approved, queue it for posting
> - **Skip this comment** — drop it entirely
> - **Revise** — the user provides additional context or corrections via the
>   "Other" free-text option; revise the comment incorporating their
>   feedback, then re-present the updated version for approval (loop until
>   approved or skipped)

review-workflow.md step 6 lists two options plus the implicit free-text
channel:

> | **Post this comment** | Queue for posting |
> | **Skip this comment** | Drop entirely, remove from summary |
> | *(Other — free text)* | User provides revision feedback |

## Problem / opportunity

The model has to construct a concrete `options` array for AskUserQuestion.
One file says to offer an explicit third option named "Revise" (whose
description then confusingly says the feedback arrives "via the 'Other'
free-text option"), the other says to offer two options and let revision
feedback come through free text. These are different UIs: an explicit
"Revise" option that the user can select without typing feedback leaves the
model with an approved-to-revise comment but no revision content. Which file
the model happens to have read last determines what the user sees.

## Grounding

Direct quotes above from the two files (read 2026-07-04). The contradiction
is internal to the skill; no external source needed.

## Proposed change

Define the option set once (in whichever file owns the approval loop after
the deduplication todo is handled) and make the other file defer to it.
The two-option variant from review-workflow.md is the self-consistent one:
"Post this comment" / "Skip this comment", with revision feedback arriving
via the free-text "Other" answer. If an explicit "Revise" option is wanted
instead, the skill must also say to follow up with a question asking what
to change, since selecting "Revise" alone carries no feedback text.

## Addition (second pass)

External grounding for "selecting 'Revise' alone carries no feedback text":
the Claude Agent SDK user-input reference
(https://code.claude.com/docs/en/agent-sdk/user-input, fetched 2026-07-04)
defines options as "2-4 choices, each with `label` and `description`" — a
selected option returns only its label as the answer value. Free text
arrives separately: "Display an additional 'Other' choice after Claude's
options that accepts text input. Use the user's custom text as the answer
value (not the word 'Other')". So the two-option-plus-Other design is the
one the tool actually supports without a follow-up question.
