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

## Severity levels

Every finding gets exactly one severity:

- **Must address**: correctness, security, or data-loss defects that should
  block the merge.
- **Should address**: real maintainability or design problems worth fixing,
  but not merge-blocking.
- **Nit**: style or preference, entirely at the author's discretion.

The finding categories used during analysis (Bugs, Design concerns, Test
gaps, Style/documentation — see
[references/review-workflow.md](references/review-workflow.md)) are search
lenses, not the severity scale: severity is judged per finding, independent of
which category surfaced it.

## Workflow

Follow these steps in order. See reference files for detailed mechanics.

### 1. Check existing discussions

```bash
glab api "projects/<ENCODED_PROJECT>/merge_requests/<IID>/discussions" --paginate
```

Always use `--paginate` — the API returns 20 discussions per page by default.
Skip findings already raised in open threads; mention prior reviewer context
in the summary only if relevant.

### 2. Fetch MR metadata and diff (parallel)

```bash
glab mr view <IID> --repo <group/project> --output json \
  --jq '{title, author: .author.username, state, diff_refs, project_id: .target_project_id}'
glab mr diff <IID> --repo <group/project> --raw
```

The `mr view` call returns title, author, state, `diff_refs`
(`base_sha`/`head_sha`/`start_sha`) and the numeric `project_id` in a single
request — no separate SHA-extraction call needed. `mr diff --raw` produces
pipe-friendly raw diff output; the default renderer is unsuitable for the
line-counting in step 3. Fallback for the raw MR object (GET is the default
method, no `--method` flag needed):

```bash
glab api "projects/<ENCODED_PROJECT>/merge_requests/<IID>"
```

### 3. Analyze the diff and compute new-file line numbers

Count lines from diff hunk headers (`@@ -old,count +new,count @@`). See
[references/gitlab-api-comments.md](references/gitlab-api-comments.md) for the
line-counting rules and which of `new_line`/`old_line` to use.

### 4. Ask the user how to proceed

Before posting anything, summarize the analysis using the severity labels
(e.g. "Found 7 findings: 2 must address, 3 should address, 2 nits"), then use
AskUserQuestion:

- **Post directly** — generate payloads and post all comments + summary at once
- **Preview first** — enter the interactive approval loop (step 5)
- **Report only** — present the findings in the conversation; post nothing to
  GitLab

### 5. Interactive approval loop (when preview mode chosen)

Present each finding one-by-one using AskUserQuestion. For each comment:

- Show the file, line number, severity, and full comment body (including any
  `suggestion` block) in the question description
- Offer exactly these options:
  - **Post this comment** — approved, queue it for posting
  - **Skip this comment** — drop it entirely
- Revision feedback arrives via the built-in "Other" free-text option: if the
  user answers with free text instead of choosing an option, revise the
  comment incorporating their feedback, then re-present the same two options
  for the updated version (loop until approved or skipped)

After all inline comments are decided, present the review summary the same way
for approval/skip/revision.

See [references/review-workflow.md](references/review-workflow.md) for the
detailed loop mechanics.

### 6. Generate approved JSON payloads via Python

ALWAYS use `json.dump()` — NEVER shell heredocs or echo. Only generate
payloads for comments that were approved in step 5. Include `suggestion:-N+M`
blocks for concrete fix proposals.

Create a fresh temp directory first:

```bash
TMP_DIR=$(mktemp -d)
```

Write one file per comment, named `mr-review-comment-<n>.json`, plus
`mr-review-summary.json`, into that directory.

### 7. Post approved comments (parallel) and summary note

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/discussions" \
  --method POST --input "$TMP_DIR/mr-review-comment-1.json" -H 'Content-Type: application/json'
```

Verify each response returns a `discussion.id`.

Summary via Notes API:

```bash
glab api "projects/<PROJECT>/merge_requests/<IID>/notes" \
  --method POST --input "$TMP_DIR/mr-review-summary.json" -H 'Content-Type: application/json'
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
- ALWAYS ask post-directly vs. preview vs. report-only before posting anything
  to GitLab, summarizing finding counts by severity in the question.
- NEVER post a comment that was skipped or not yet approved in preview mode.
- When a user provides revision feedback via "Other", incorporate it and
  re-present — do NOT post the original version.

## Reference files

| Task | Reference |
|------|-----------|
| Posting inline comments, SHA extraction, suggestion syntax | [references/gitlab-api-comments.md](references/gitlab-api-comments.md) |
| Full review workflow, approval loop, severity categories | [references/review-workflow.md](references/review-workflow.md) |
