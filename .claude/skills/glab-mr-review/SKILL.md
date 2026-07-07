---
name: glab-mr-review
description: >-
  Review GitLab merge requests with inline diff comments and suggestions via
  the glab CLI and GitLab API.
when_to_use: >-
  Review an MR or merge request; post or add review comments on a GitLab MR;
  code review on a GitLab-hosted repository.
---

## When to use

Use this skill when asked to review a GitLab merge request, add inline code
review comments, or post review summaries. Requires `glab` CLI authenticated
with the target GitLab instance.

## Workflow

Follow these steps in order. See reference files for detailed mechanics.

### 1. Fetch MR info and diff (parallel)

```bash
glab mr view <IID> --repo <group/project>
glab mr diff <IID> --repo <group/project>
```

### 2. Extract SHA refs for positioning inline comments

```bash
glab api "projects/<ENCODED_PROJECT>/merge_requests/<IID>" --method GET
```

Parse `diff_refs.base_sha`, `diff_refs.head_sha`, `diff_refs.start_sha`.

### 3. Analyze the diff and compute new-file line numbers

Count lines from diff hunk headers (`@@ -old,count +new,count @@`). See
[references/gitlab-api-comments.md](references/gitlab-api-comments.md) for the
line-counting rules and which of `new_line`/`old_line` to use.

### 4. Ask the user: post directly or preview?

Before posting anything, use AskUserQuestion:

- **Post directly** — generate payloads and post all comments + summary at once
- **Preview first** — enter the interactive approval loop (step 5)

### 5. Interactive approval loop (when preview mode chosen)

Present each finding one-by-one using AskUserQuestion. For each comment:

- Show the file, line number, severity, and full comment body (including any
  `suggestion` block) in the question description
- Offer these options:
  - **Post this comment** — approved, queue it for posting
  - **Skip this comment** — drop it entirely
  - **Revise** — the user provides additional context or corrections via the
    "Other" free-text option; revise the comment incorporating their feedback,
    then re-present the updated version for approval (loop until approved or
    skipped)

After all inline comments are decided, present the review summary the same way
for approval/skip/revision.

See [references/review-workflow.md](references/review-workflow.md) for the
detailed loop mechanics.

### 6. Generate approved JSON payloads via Python

ALWAYS use `json.dump()` — NEVER shell heredocs or echo. Only generate
payloads for comments that were approved in step 5. Include
````suggestion:-N+M` blocks for concrete fix proposals.

### 7. Post approved comments (parallel) and summary note

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/discussions" \
  --method POST --input /tmp/comment.json -H 'Content-Type: application/json'
```

Summary via Notes API:

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/notes" \
  --method POST --input /tmp/summary.json -H 'Content-Type: application/json'
```

The summary MUST only reference comments that were actually posted. If comments
were skipped during the approval loop, remove them from the summary.

## Critical rules

- The `-H 'Content-Type: application/json'` header is REQUIRED on every
  `--input` call. Without it: HTTP 415.
- NEVER guess line numbers. Compute them from diff hunk headers.
- NEVER build JSON payloads with shell strings. Use Python `json.dump()`.
- URL-encode project paths: `group/project` -> `group%2Fproject`.
- Categorize findings in the summary: **Must address** / **Should address** / **Nit**.
- ALWAYS ask post-directly vs. preview before posting anything to GitLab.
- NEVER post a comment that was skipped or not yet approved in preview mode.
- When a user provides revision feedback via "Other", incorporate it and
  re-present — do NOT post the original version.

## Decision tree

| Task | Reference |
|------|-----------|
| Posting inline comments, SHA extraction, suggestion syntax | [references/gitlab-api-comments.md](references/gitlab-api-comments.md) |
| Full review workflow, approval loop, severity categories | [references/review-workflow.md](references/review-workflow.md) |
