# Code Review Workflow

## Step-by-step process

### 1. Fetch MR metadata and diff

Run in parallel:

```bash
glab mr view <IID> --repo <group/project>
```

```bash
glab mr diff <IID> --repo <group/project>
```

The `view` gives title, author, labels, state. The `diff` gives the full
unified diff of all changed files.

### 2. Extract SHA references for inline comments

```bash
glab api "projects/<ENCODED_PROJECT>/merge_requests/<IID>" --method GET
```

Parse `diff_refs.base_sha`, `diff_refs.head_sha`, `diff_refs.start_sha` from
the response. These are required for every inline comment.

### 3. Analyze the diff

Read the diff carefully. For each changed file, identify:

- **Bugs**: logic errors, off-by-one, null safety issues, edge cases
- **Design concerns**: silent data loss, unclear error semantics, missing
  validation, broken contracts
- **Test gaps**: missing edge cases, hardcoded values that should reference
  constants, insufficient assertions
- **Style/documentation**: misleading names, missing doc for non-obvious
  behavior, dead code

### 4. Compute line numbers

For each comment, determine the exact `new_line` (for added/modified lines) or
`old_line` (for removed lines) from the diff hunk headers.

See [gitlab-api-comments.md](gitlab-api-comments.md) for the line-counting
procedure.

### 5. Ask: post directly or preview?

Before posting anything, use AskUserQuestion to let the user choose:

- **Post directly** — skip to step 7
- **Preview first** — enter the interactive approval loop (step 6)

### 6. Interactive approval loop

Present each finding one at a time using AskUserQuestion. The question should
contain the full context the user needs to decide:

**Question format:**

> **[Severity] `file:line`** — one-line title
>
> Full comment body including any `suggestion` block, shown in the description.

**Options (single-select):**

| Option | Behavior |
|--------|----------|
| **Post this comment** | Queue for posting |
| **Skip this comment** | Drop entirely, remove from summary |
| *(Other — free text)* | User provides revision feedback |

**Revision loop:** When the user selects "Other" and provides feedback,
incorporate their input into a revised version of the comment, then re-present
the updated comment with the same options. Repeat until the user either
approves or skips.

After all inline comments are decided, present the **review summary** the same
way. The summary MUST only reference comments that were approved. Adjust
severity sections — drop empty categories entirely.

### 7. Generate approved JSON payloads

Use a single Python script to generate payloads for **approved comments only**.
This avoids shell escaping issues and ensures consistent SHA references.

```python
import json

BASE_SHA = "..."
HEAD_SHA = "..."
START_SHA = "..."

def pos(path, new_line):
    return {
        "position_type": "text",
        "base_sha": BASE_SHA,
        "head_sha": HEAD_SHA,
        "start_sha": START_SHA,
        "old_path": path,
        "new_path": path,
        "new_line": new_line,
    }

comments = [
    {
        "body": "Review comment with optional\n\n```suggestion:-0+0\n    replacement\n```",
        "position": pos("src/File.php", 42),
    },
    # ... only approved comments
]

for i, c in enumerate(comments):
    path = f"/tmp/mr-review-comment-{i+1}.json"
    with open(path, "w") as f:
        json.dump(c, f)
    print(f"Wrote {path}")
```

### 8. Post approved inline comments

Post all approved comment files in parallel:

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/discussions" \
  --method POST \
  --input /tmp/mr-review-comment-1.json \
  -H 'Content-Type: application/json'
```

Verify each returns a `discussion.id` in the response.

### 9. Post the review summary

Write a summary note categorizing findings by severity:

```markdown
## Code Review Summary — MR !<IID> "<title>"

**Overall**: Brief assessment of the change quality and scope.

### Must address
1. **Issue name** (`file:line`) — Description

### Should address
2. **Issue name** (`file:line`) — Description

### Nit
3. **Issue name** (`file:line`) — Description
```

Post via the Notes API:

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/notes" \
  --method POST \
  --input /tmp/mr-summary.json \
  -H 'Content-Type: application/json'
```

## Review comment quality guidelines

- **Be specific**: reference exact line numbers and variable names
- **Explain the why**: don't just say "this is wrong" — explain the consequence
  (data loss, wasted API call, test fragility)
- **Suggest fixes**: use `suggestion` blocks for concrete changes; use prose for
  design-level questions where there's more than one valid approach
- **Ask, don't demand**: for design decisions, phrase as questions ("Is this
  intentional?") rather than directives
- **Categorize severity**: reviewers reading summaries should immediately know
  what blocks merge vs. what's optional

## Anti-patterns

- NEVER post comments without first extracting the correct SHA refs — stale or
  guessed SHAs cause silent failures or misplaced comments
- NEVER use shell heredocs or `echo` to build JSON payloads — backticks and
  newlines in suggestion blocks will break
- NEVER hardcode line numbers without computing them from the diff hunk headers
- NEVER omit the `-H 'Content-Type: application/json'` header on `--input`
  calls — HTTP 415 error
