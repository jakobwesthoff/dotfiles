# GitLab API: Inline MR Comments

## Overview

`glab mr` does not support inline diff comments natively. Use `glab api` to
call the GitLab Discussions and Notes REST endpoints directly.

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
current head of the MR branch — stale SHAs cause 400 errors.

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

## Posting Inline Comments (Discussions API)

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

**CRITICAL:** The `-H 'Content-Type: application/json'` header is REQUIRED when
using `--input`. Without it, the API returns HTTP 415 Unsupported Media Type.

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
