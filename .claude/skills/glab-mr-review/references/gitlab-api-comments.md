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

### Which line field to use

| Line type | Set `new_line` | Set `old_line` |
|-----------|---------------|---------------|
| Added (`+` in diff) | Yes | No |
| Removed (`-` in diff) | No | Yes |
| Context (unchanged) | Yes | Yes (optional) |

For comments on added lines, use `new_line` only. NEVER set both fields on an
added line — the API will reject it or anchor the comment incorrectly.

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

`old_path` and `new_path` are identical for modified files. They differ only
when a file was renamed.

### Posting with glab api

Write the JSON payload to a temp file, then post with the Content-Type header:

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/discussions" \
  --method POST \
  --input /tmp/comment.json \
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

with open("/tmp/comment.json", "w") as f:
    json.dump(comment, f)
```

## Posting a Summary Note (Notes API)

For the overall review summary, use the Notes endpoint (not Discussions):

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/notes" \
  --method POST \
  --input /tmp/summary.json \
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
