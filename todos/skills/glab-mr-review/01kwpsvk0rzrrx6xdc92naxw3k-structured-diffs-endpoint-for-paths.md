# `old_path`/`new_path` guidance is incomplete for added files and renames; the structured diffs endpoint solves both

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, "JSON payload structure" (paths note) and "Computing Line Numbers"

## Current state

> `old_path` and `new_path` are identical for modified files. They differ only
> when a file was renamed.

The skill's only diff source is the human-oriented `glab mr diff` text
output. Nothing says what `old_path` should be for an added file (which has
no old version), and nothing gives a way to obtain the correct path pair for
a renamed file other than parsing `rename from`/`rename to` headers out of
the raw diff text.

## Problem / opportunity

- Added files: a model must guess whether to send `old_path` at all, send
  `null`, or repeat the new path. Wrong guesses hit the position
  completeness validation (both paths must be present for text and file
  positions).
- Renamed files: the paths must be taken from the rename data; the skill
  provides no procedure.
- GitLab exposes a structured, machine-readable per-file diff list that
  answers both, plus flags for new/deleted/renamed/generated files, so no
  header parsing is needed.

## Grounding

- Live read-only call (2026-07-04):
  `GET https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/merge_requests/3099/diffs`
  returns one entry per changed file with keys `old_path`, `new_path`,
  `new_file`, `deleted_file`, `renamed_file`, `generated_file`, `diff`,
  `a_mode`, `b_mode`, `collapsed`, `too_large`. For every `new_file: true`
  entry, `old_path` equals `new_path` (e.g. both
  `internal/commands/mr/note/helpers.go`) — GitLab itself uses the new path
  in both fields for added files, so payloads should do the same.
- Server-side completeness requires both paths for file positions
  (`lib/gitlab/diff/formatters/file_formatter.rb`, `complete?` checks
  `[new_path, old_path].all?(&:present?)`; master, fetched 2026-07-04).
- glab's own diff-comment implementation takes both paths from the
  structured diff entry rather than from diff text:
  `internal/commands/mr/mrutils/position.go` (v1.105.0) sets
  `NewPath: fileDiff.NewPath, OldPath: fileDiff.OldPath` from the MR diff
  version object.
- The endpoint is paginated like all list endpoints (default 20 per page),
  so `--paginate` applies (see the existing pagination todo).

## Proposed change

1. Replace the quoted paths note with: take `old_path` and `new_path` for
   each file from `glab api "projects/<ID>/merge_requests/<IID>/diffs" --paginate`
   and copy them into the position verbatim. State that for added files
   GitLab reports `old_path` equal to `new_path`, and that renames are
   detected via `renamed_file: true` (with the differing paths already
   filled in).
2. Optionally note this endpoint also returns the per-file `diff` text, so
   it can replace `glab mr diff` as the input to line counting when
   structured per-file processing is preferred.
