# GitLab API: Inline MR Comments

## Overview

The primary route for inline comments is the raw API: create draft notes via
the Draft Notes API, publish them atomically, then post the summary via the
Notes API (see the sections below). `glab mr note create --file <path> --line
N` (or `--line N:M` for ranges, `--old-line N` for removed lines) is a native
alternative for a single ad-hoc diff comment, always anchored to the latest
merge request diff version; it is marked EXPERIMENTAL in glab 1.107.0's help
output. The raw API stays primary for this skill's review workflow because
the native command cannot set both `old_line` and `new_line` together (needed
for context-line comments), offers no draft-note staging, and cannot pin an
older diff version. If the native command is used for a one-off comment, pipe
the body from stdin or a file rather than `-m` to avoid shell-escaping issues
with suggestion blocks, and pass `--unique` to skip posting if an identical
comment already exists.

## Required SHA References

Every inline comment requires three SHAs that anchor it to a specific diff
version. Extract them from the MR metadata:

```bash
glab api "projects/<URL-ENCODED-PROJECT>/merge_requests/<IID>" --method GET \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('base_sha:', d['diff_refs']['base_sha'])
print('head_sha:', d['diff_refs']['head_sha'])
print('start_sha:', d['diff_refs']['start_sha'])
"
```

All three fields come from `diff_refs` on the MR object. They MUST match the
current head of the MR branch. Wrong or stale SHAs fail unpredictably:

- Unresolvable line numbers (a line that does not exist in the resolved diff)
  or an incomplete position (missing required line fields) return HTTP 400.
- Mismatched `base_sha`/`head_sha`/`start_sha` combinations return HTTP 500
  (`Failed to find diff line for: <file>, old_line: N, new_line: N`) or create
  a comment that renders as a broken attachment link instead of an inline
  thread (gitlab-org/gitlab#296829).

Both failure classes are avoided the same way: always fetch `diff_refs` fresh
from the same MR immediately before posting, and compute lines from the
current diff rather than reusing values from an earlier session.

## Computing Line Numbers

Line numbers in the `position` object refer to the **file** line number in
either the old or new version, NOT the diff hunk offset.

### From a unified diff hunk header

```
@@ -309,6 +315,10 @@
```

- Old file: 6 lines starting at line 309
- New file: 10 lines starting at line 315

Count forward from the new-file start (`315`) for each line in the hunk.
Context lines (no `+`/`-` prefix) and added lines (`+` prefix) both increment
the new-file counter. Removed lines (`-` prefix) do NOT increment it.

Track the old-file counter the same way, starting at the old start from the
hunk header (`309`). Context lines and removed (`-`) lines increment the
old-file counter; added (`+`) lines do not. For a context line, both counters
must be tracked in parallel and both values sent — they diverge as soon as an
earlier line in the hunk was added or removed, so the old-file line number
cannot be inferred from the new-file line number.

Lines beginning with `\` (`\ No newline at end of file`) are diff metadata,
not file lines. They increment neither the old-file nor the new-file counter
and must be skipped when counting, even though they carry no `+`/`-` prefix.
This marker can appear mid-hunk, immediately after the old file's last line,
as well as at the end of the hunk.

### Which line field to use

| Line type | Set `new_line` | Set `old_line` |
|-----------|---------------|---------------|
| Added (`+` in diff) | Yes | No |
| Removed (`-` in diff) | No | Yes |
| Context (unchanged) | Yes | Yes (required) |

For comments on added lines, use `new_line` only. NEVER set both fields on an
added line — the API will reject it or anchor the comment incorrectly.

For comments on a context (unchanged) line, GitLab requires BOTH
`position[new_line]` and `position[old_line]`. Compute both from the
respective counters above; they are generally not equal.

## Draft Notes API

Default mechanism for posting inline review comments. Draft notes remain
visible only to their author until published, so a whole review is staged
first and published atomically instead of trickling in comment by comment.

### Create

Endpoint: `POST /projects/:id/merge_requests/:merge_request_iid/draft_notes`

The payload uses the `note` key for the comment body, NOT `body` — `body` is
the Discussions/Notes API key. This is an easy silent mistake since the rest
of this skill's payloads use `body` for the summary. The `position` object is
identical to the Discussions API's (same required SHAs, `position_type`,
`old_path`/`new_path`, and the same optional `line_range` structure described
below).

```json
{
  "note": "Comment text with optional ```suggestion blocks",
  "position": {
    "position_type": "text",
    "base_sha": "<from diff_refs>",
    "head_sha": "<from diff_refs>",
    "start_sha": "<from diff_refs>",
    "old_path": "src/Example.php",
    "new_path": "src/Example.php",
    "new_line": 42
  }
}
```

```bash
glab api "projects/<PROJECT_ID>/merge_requests/<IID>/draft_notes" \
  --method POST \
  --input "$TMP_DIR/mr-review-comment-1.json" \
  -H 'Content-Type: application/json'
```

GitLab's REST reference documents no response example for this endpoint. The
list/get endpoints (`GET .../draft_notes`, `GET .../draft_notes/:id`) show the
draft note object with a top-level `id` field; expect the same shape back
from a successful create.

### Publish

Publish one: `PUT /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id/publish`.

Publish all (used by this skill after the approval loop, so the whole review
appears at once): `POST /projects/:id/merge_requests/:merge_request_iid/draft_notes/bulk_publish`.

```bash
glab api "projects/<PROJECT_ID>/merge_requests/<IID>/draft_notes/bulk_publish" \
  --method POST -H 'Content-Type: application/json'
```

GitLab's REST docs (https://docs.gitlab.com/api/draft_notes/) document no
request or response body for this endpoint beyond the path parameters.
GitLab's source on `master` (`lib/api/draft_notes.rb`) sets `status 204` /
`body false` at the end of the endpoint, so `bulk_publish` returns
`204 No Content` on success. The same source additionally accepts three
optional parameters — `reviewer_state` (`requested_changes`/`reviewed`),
`note` (a summary body to post on the MR in the same call), and `internal`
(boolean) — but these are undocumented in the public REST reference and only
verified against `master`; older self-hosted instances may not support them.
This skill relies only on the documented baseline: create drafts, then a
plain `bulk_publish` with no body, then post the summary separately via the
Notes API.

### List and delete

List: `GET .../draft_notes`. Delete (escape hatch for discarding a staged
draft before publishing): `DELETE .../draft_notes/:draft_note_id`.

## Posting Inline Comments (Discussions API)

Fallback for positions the Draft Notes API rejects, and alternative for
posting a single ad-hoc comment outside the staged-review flow. The payload
shape is otherwise identical to a draft note's, except the body key is
`body`, not `note`.

Endpoint: `POST /projects/:id/merge_requests/:iid/discussions`

### JSON payload structure

```json
{
  "body": "Comment text with optional ```suggestion blocks",
  "position": {
    "position_type": "text",
    "base_sha": "<from diff_refs>",
    "head_sha": "<from diff_refs>",
    "start_sha": "<from diff_refs>",
    "old_path": "src/Example.php",
    "new_path": "src/Example.php",
    "new_line": 42
  }
}
```

Take `old_path` and `new_path` for each file from
`glab api "projects/<PROJECT_ID>/merge_requests/<IID>/diffs" --paginate` and
copy them into the position verbatim rather than inferring them from `glab mr
diff` text. For added files, GitLab reports `old_path` equal to `new_path` —
send the same value in both fields. Renames are flagged by `renamed_file:
true` on the entry, with `old_path`/`new_path` already holding the differing
paths. The endpoint is paginated (default 20 per page), so `--paginate`
applies. Each entry's `diff` field also holds the per-file unified diff text,
so this endpoint can replace `glab mr diff` as the input to line counting
when structured per-file processing is preferred.

### Posting with glab api

Write the JSON payload to a temp file, then post with the Content-Type header:

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/discussions" \
  --method POST \
  --input "$TMP_DIR/mr-review-comment-1.json" \
  -H 'Content-Type: application/json'
```

A successful positioned discussion POST returns `201` with a top-level `id`
field (there is no `discussion` wrapper key).

**CRITICAL:** The `-H 'Content-Type: application/json'` header is REQUIRED when
using `--input`. `glab api --input` sends the file as a raw request body with
only a `Content-Length` header, no default Content-Type, so the JSON content
type must be supplied explicitly with `-H`; without it, the request fails
(observed: HTTP 415 Unsupported Media Type).

### Fallback when a position is rejected

Both the Draft Notes API and the Discussions API can reject a `position` (see
"Required SHA References" above for the failure modes). When a positioned
create fails:

1. Re-verify the computed `old_line`/`new_line` against the hunk headers and
   re-fetch `diff_refs` (the MR may have been updated since analysis), then
   retry once with the corrected values.
2. If it still fails, demote the comment to a plain (position-less)
   discussion: `POST .../discussions` with only `body`, prefixed with
   `**file:line**` so the location is still visible. Convert any `suggestion`
   block in the body into a plain fenced code block first — suggestions are
   only valid inside diff-positioned discussions or draft notes, never in a
   position-less thread.
3. Report which comments ended up posted inline (as drafts or discussions)
   and which were demoted to plain threads.

### Generating payloads safely

ALWAYS use Python's `json.dump()` to produce payload files. Shell heredocs and
`echo` silently break on backticks, quotes, and newlines inside suggestion
blocks.

```python
import json

comment = {
    "body": "Your review comment here.\n\n```suggestion:-0+0\n    replacement line\n```",
    "position": {
        "position_type": "text",
        "base_sha": BASE_SHA,
        "head_sha": HEAD_SHA,
        "start_sha": START_SHA,
        "old_path": "src/Example.php",
        "new_path": "src/Example.php",
        "new_line": 42,
    },
}

with open(f"{TMP_DIR}/mr-review-comment-1.json", "w") as f:
    json.dump(comment, f)
```

### Multiline comments

A comment can highlight a range of lines instead of a single line by adding
`position[line_range]`. Each of `line_range.start` and `line_range.end` is an
object with `line_code` (required) and `type` (required), plus optional
nested `old_line`/`new_line`.

- `type` is `"new"` for a line added by this commit, `"old"` otherwise.
- `line_code` has the form `<SHA1-of-new_path>_<old_line>_<new_line>`, for
  example `adc83b19e793491b1c6ea0fd8b46cd9f32e292fc_5_5`. Compute it as
  `hashlib.sha1(new_path.encode()).hexdigest() + f"_{old_line}_{new_line}"`,
  using the old-file and new-file line numbers for that specific start or end
  line (from the counters described in "Computing Line Numbers").
- The top-level `new_line`/`old_line` fields are still required even when
  `line_range` is present, and must be set to the END line of the range, not
  the start. GitLab anchors the note at the top-level position; `line_range`
  only defines the highlighted span.

```json
{
  "body": "This whole block should be extracted into a helper.",
  "position": {
    "position_type": "text",
    "base_sha": "<from diff_refs>",
    "head_sha": "<from diff_refs>",
    "start_sha": "<from diff_refs>",
    "old_path": "src/Example.php",
    "new_path": "src/Example.php",
    "new_line": 45,
    "line_range": {
      "start": {
        "line_code": "adc83b19e793491b1c6ea0fd8b46cd9f32e292fc_40_42",
        "type": "new",
        "new_line": 42
      },
      "end": {
        "line_code": "adc83b19e793491b1c6ea0fd8b46cd9f32e292fc_43_45",
        "type": "new",
        "new_line": 45
      }
    }
  }
}
```

### File-level comments

A comment can attach to a file as a whole rather than a line, for findings
like wrong file location, a file that should be split, or a missing license
header. Set `position_type` to `"file"` and include both `old_path` and
`new_path` with no line fields at all:

```json
{
  "body": "This file should live under src/Legacy/ given its deprecation status.",
  "position": {
    "position_type": "file",
    "base_sha": "<from diff_refs>",
    "head_sha": "<from diff_refs>",
    "start_sha": "<from diff_refs>",
    "old_path": "src/Example.php",
    "new_path": "src/Example.php"
  }
}
```

This requires GitLab 16.4 or later.

`glab mr note create <IID> --file <path>` (without `--line`/`--old-line`)
does NOT produce this. glab instead builds a `position_type: "text"` position
anchored to the first targetable line of the file's diff — a line-anchored
comment, not a true file-scoped one. Use the raw API payload above to get an
actual `position_type: "file"` comment.

## Posting a Summary Note (Notes API)

For the overall review summary, use the Notes endpoint (not Discussions):

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/notes" \
  --method POST \
  --input "$TMP_DIR/mr-review-summary.json" \
  -H 'Content-Type: application/json'
```

Payload:

```json
{
  "body": "## Code Review Summary\n\n..."
}
```

## GitLab Suggestion Syntax

Embed code suggestions in comment bodies using fenced blocks:

````
```suggestion:-N+M
replacement code
```
````

Where:
- `-N` = number of lines **above** the commented line to include in the replacement
- `+M` = number of lines **below** the commented line to include
- Total replaced range: `(commented_line - N)` through `(commented_line + M)`, inclusive
- `-0+0` replaces only the commented line itself
- GitLab limits `N` and `M` to 100 each (100 lines above, 100 lines below),
  for a maximum of 201 changed lines per suggestion
- Suggestion blocks are only applicable inside diff-positioned discussion
  comments or draft notes. Never put a suggestion block in the summary note —
  it has no diff position to apply against.

### Examples

Replace just the commented line:
````
```suggestion:-0+0
    public const LIMIT = 20;
```
````

Replace the commented line plus 2 lines below (3 lines total):
````
```suggestion:-0+2
    'name' => 'example',
    'value' => Config::LIMIT,
    'enabled' => true,
```
````

Replace 1 line above, the commented line, and 2 below (4 lines total):
````
```suggestion:-1+2
    'single_request_at_limit' => [
        'totalIds' => Config::MAX_PER_REQUEST,
        'expectedCount' => 1,
        'expectedSizes' => [Config::MAX_PER_REQUEST],
```
````

## Follow-up operations

Re-review scenarios (respond to an author's answer on a thread, resolve a
thread whose finding was addressed, reopen one) use different endpoints than
creating new comments.

- **Reply to an existing discussion**: `POST /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id/notes`
  with required `body`. Returns `201` and the created note.
- **Resolve or reopen a thread**: `PUT /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id`
  with boolean `resolved` (`true` to resolve, `false` to reopen). Returns
  `200` and the updated discussion. Post the boolean via
  `glab api ... --method PUT --field resolved=true`, since `--field` converts
  literal `true`/`false` to JSON booleans.
- **Native alternative**: `glab mr note resolve <discussion-id> <IID>` and
  `glab mr note reopen <discussion-id> <IID>` exist and are marked
  EXPERIMENTAL in glab 1.107.0's help output.
- **Inspecting existing threads**: `glab mr view <IID> --comments` shows
  comments and activity; `--resolved` or `--unresolved` filter to just
  resolved or unresolved discussions (each implies `--comments`).

## Project path encoding

The numeric project ID needs no encoding and is the preferred way to address
the project in `glab api` paths. SKILL.md step 2 already fetches it: the
`glab mr view --output json` call's `--jq` filter includes `project_id:
.target_project_id`. Build API paths as
`projects/<PROJECT_ID>/merge_requests/<IID>/...` with that value.

When only the project path is known, URL-encode it — slashes become `%2F`:

- `acme/service-api` -> `acme%2Fservice-api`

`glab api` has no `--repo` flag. When the shell's working directory is
inside the target repository, use `projects/:fullpath/merge_requests/<IID>/...`
instead; `glab api` substitutes `:fullpath` with the URL-encoded project path
of the current directory's repository automatically. To target a project on a
different GitLab host than the current directory's authenticated one, pass
`--hostname <host>`.
