# File-level comments (`position_type: file` / `glab mr note create --file` without line) are not covered

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md` (position payload documentation)

## Current state

The skill only documents line-anchored comments (`position_type: "text"`
with `new_line`/`old_line`). Findings that concern a file as a whole (wrong
location, file should be split, missing license header, binary file
concerns) have no documented mechanism other than forcing them onto an
arbitrary line.

## Problem / opportunity

GitLab supports file-scoped diff comments. Anchoring whole-file findings to
line 1 (the workaround a model would improvise) misattributes the finding
and breaks if line 1 is not part of the diff.

## Grounding

- GitLab Discussions API (https://docs.gitlab.com/api/discussions/, fetched
  2026-07-04): `position[position_type]` "Type of the position reference.
  Allowed values: `text`, `image`, or `file`."
- GitLab Draft Notes API (https://docs.gitlab.com/api/draft_notes/, fetched
  2026-07-04): position type `file` "introduced in GitLab 16.4".
- Native support in glab 1.105.0 (`glab mr note create --help`, local,
  2026-07-04): "Use `--file` to place a diff comment on a specific file in
  the latest merge request diff version. ... Omit both flags for a
  file-level comment." Help example: `glab mr note create 123 --file main.go
  -m "General comment on this file"`. (Feature marked experimental.)

## Proposed change

Document file-level comments as the mechanism for whole-file findings:
`position_type: "file"` with `old_path`/`new_path` and the three SHAs, no
line fields; or the native `glab mr note create <IID> --file <path>`.

## Second pass grounding

Both open points are settled from GitLab sources (fetched 2026-07-04); no
sandbox test needed.

**Exact accepted payload.** GitLab source (master):

- `lib/api/discussions.rb` requires in `position`: `base_sha`, `start_sha`,
  `head_sha`, `position_type` (values `text image file`); `new_path` /
  `old_path` are optional at the API layer.
- `lib/gitlab/diff/formatters/file_formatter.rb`:
  `def complete? [new_path, old_path].all?(&:present?)` — BOTH paths must be
  present or DiffNote's `positions_complete` validation rejects with
  "position is incomplete" (400). The formatter reads no line fields at all.
- Worked 201 example in `spec/requests/api/discussions_spec.rb` (added by
  merged MR gitlab-org/gitlab!130404), context "when position_type is file":
  takes a full text position hash and merely switches
  `position_type: 'file'`; expects `:created`.
- File positions skip the diff-line machinery: in `app/models/diff_note.rb`,
  `line_code` validation and `create_diff_file` (the
  `NoteDiffFileCreationError` 500 path) are conditional on `on_text?`, so
  they do not apply to file positions.

Minimal validated payload:

```json
{
  "body": "...",
  "position": {
    "position_type": "file",
    "base_sha": "<diff_refs>", "head_sha": "<diff_refs>", "start_sha": "<diff_refs>",
    "old_path": "path/to/file",
    "new_path": "path/to/file"
  }
}
```

(For added files GitLab itself reports `old_path` equal to `new_path` in the
MR diffs endpoint — verified live read-only on gitlab-org/cli MR !3099,
2026-07-04 — so the same value in both fields is correct there too.)

**Version requirement.** The Discussions API docs themselves state: "Allowed
values: `text`, `image`, or `file`. `file` introduced in GitLab 16.4"
(https://docs.gitlab.com/api/discussions/, linking issue
gitlab-org/gitlab#423046; implemented by MR !130404 which added `file` to
the Grape `values:` list). So >= 16.4 applies to the Discussions API, same
as Draft Notes.

## Correction (second pass)

The Grounding section above implies the native
`glab mr note create <IID> --file <path>` (no line flags) is an equivalent
route to a GitLab file-level comment. It is not. glab's implementation
(`internal/commands/mr/mrutils/position.go`, identical on `main` and the
installed `v1.105.0`) never sends `position_type: "file"`: for `--file`
without `--line`/`--old-line` it builds a `position_type: "text"` position
anchored to the FIRST targetable line of the file's diff (first added,
removed, or context line — the `lineStart == 0 && oldLine == 0` branch).
The help text "Omit both flags for a file-level comment" describes intent,
not the payload. If the skill documents the native route, it must say the
result is a line-anchored comment on the first diff line, not a true
file-scoped comment; only the raw-API payload above produces
`position_type: "file"`.
