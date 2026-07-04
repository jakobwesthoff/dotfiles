# Suggestion syntax section lacks the 100-lines-above/below limit and the diff-thread requirement

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, section "GitLab Suggestion Syntax"

## Current state

The section defines `-N`/`+M` semantics and gives examples, but states no
limit on the range and does not say where suggestion blocks are valid. The
skill elsewhere (SKILL.md step 6) says to include suggestion blocks "for
concrete fix proposals" without constraining which comments can carry them.

## Problem / opportunity

- Without the documented range limit, a large generated suggestion can
  silently exceed what GitLab accepts as an applicable suggestion.
- Suggestions are a diff-thread feature. A suggestion block placed in the
  summary note (posted via the Notes API, no position) is not applicable;
  the skill should tell the model to keep suggestion blocks out of the
  summary and only in positioned discussions.

## Grounding

GitLab docs "Suggest changes"
(https://docs.gitlab.com/user/project/merge_requests/reviews/suggestions/,
fetched 2026-07-04):

- "GitLab limits multi-line suggestions to 100 lines above and 100 lines
  below the commented diff line. This allows for up to 201 changed lines per
  suggestion."
- Suggestions must be created in merge request diff threads (the UI flow
  requires adding a comment anchored to a diff line before inserting a
  suggestion).
- `-N+M` semantics confirmed: `-N` = N lines above the commented line,
  `+M` = M lines below (matches the skill's existing description).
- Applying a suggestion requires being the MR author or having at least the
  Developer role on the project.

## Proposed change

Add to the "GitLab Suggestion Syntax" section:

- Range limit: at most 100 lines above and 100 lines below the commented
  line (max 201 lines per suggestion).
- Suggestion blocks are only applicable inside diff-positioned discussion
  comments; never put a suggestion block in the summary note.
