# Code Review Workflow Reference

This reference supplements the step-by-step workflow in
[SKILL.md](../SKILL.md). It covers material the workflow doesn't spell out:
finding categories, the approval-loop question format, the payload-generation
script, the summary template, review quality guidelines, and anti-patterns.

## Table of contents

- [Finding categories](#finding-categories)
- [Approval-loop question format](#approval-loop-question-format)
- [Generating approved JSON payloads](#generating-approved-json-payloads)
- [Review summary template](#review-summary-template)
- [Review comment quality guidelines](#review-comment-quality-guidelines)
- [Anti-patterns](#anti-patterns)

## Finding categories

When analyzing the diff, look for:

- **Bugs**: logic errors, off-by-one, null safety issues, edge cases
- **Design concerns**: silent data loss, unclear error semantics, missing
  validation, broken contracts
- **Test gaps**: missing edge cases, hardcoded values that should reference
  constants, insufficient assertions
- **Style/documentation**: misleading names, missing doc for non-obvious
  behavior, dead code

These categories are search lenses for the analysis pass, not the severity
scale. Severity (Must address / Should address / Nit — see SKILL.md's
Severity levels) is judged per finding, independent of which category
surfaced it: a "Bug" is usually Must address, but a hypothetical edge case
found while looking for bugs may only be Should address.

## Approval-loop question format

Each finding presented during the interactive approval loop follows this
format:

> **[Severity] `file:line`** — one-line title
>
> Full comment body including any `suggestion` block, shown in the
> description.

Offer exactly two options, plus the tool's built-in "Other" free-text channel
for revision feedback:

| Option | Effect |
|--------|--------|
| **Post this comment** | Queue for posting |
| **Skip this comment** | Drop entirely, remove from summary |
| *(Other — free text)* | User provides revision feedback |

When the user answers with free text via "Other", revise the comment
incorporating their feedback and re-present it with the same two options,
looping until the user picks "Post this comment" or "Skip this comment".

## Generating approved JSON payloads

Use a single Python script to generate payloads for approved comments only.
This avoids shell escaping issues and ensures consistent SHA references across
all comments. Inline comments are posted as draft notes (see
[gitlab-api-comments.md](gitlab-api-comments.md#draft-notes-api)), whose
payload key is `note`; the summary is posted separately via the Notes API,
whose payload key is `body`.

```python
import json
import os

TMP_DIR = "..."  # from `mktemp -d`
BASE_SHA = "..."
HEAD_SHA = "..."
START_SHA = "..."

def pos(path, new_line, old_line=None):
    p = {
        "position_type": "text",
        "base_sha": BASE_SHA,
        "head_sha": HEAD_SHA,
        "start_sha": START_SHA,
        "old_path": path,
        "new_path": path,
        "new_line": new_line,
    }
    if old_line is not None:
        p["old_line"] = old_line
    return p

comments = [
    {
        "note": "Review comment with optional\n\n```suggestion:-0+0\n    replacement\n```",
        "position": pos("src/File.php", 42),
    },
    # ... only approved comments
]

for i, c in enumerate(comments):
    path = os.path.join(TMP_DIR, f"mr-review-comment-{i+1}.json")
    with open(path, "w") as f:
        json.dump(c, f)
    print(f"Wrote {path}")

summary = {"body": "## Code Review Summary\n\n..."}
summary_path = os.path.join(TMP_DIR, "mr-review-summary.json")
with open(summary_path, "w") as f:
    json.dump(summary, f)
print(f"Wrote {summary_path}")
```

## Review summary template

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

- NEVER post comments without first extracting the correct SHA refs. Wrong or
  stale SHAs fail unpredictably: unresolvable line numbers or incomplete
  positions return HTTP 400, while mismatched `base_sha`/`head_sha`/`start_sha`
  combinations return HTTP 500 (`Failed to find diff line for ...`) or produce
  a broken comment rendered as an attachment link instead of an inline thread.
  Always fetch `diff_refs` fresh from the same MR immediately before posting.
- NEVER use shell heredocs or `echo` to build JSON payloads — backticks and
  newlines in suggestion blocks will break
- NEVER hardcode line numbers without computing them from the diff hunk headers
- NEVER omit the `-H 'Content-Type: application/json'` header on `--input`
  calls — `glab api --input` sends no default Content-Type, and the request
  fails (observed: HTTP 415)
