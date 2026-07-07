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

## Approval-loop question format

Each finding presented during the interactive approval loop follows this
format:

> **[Severity] `file:line`** — one-line title
>
> Full comment body including any `suggestion` block, shown in the
> description.

## Generating approved JSON payloads

Use a single Python script to generate payloads for approved comments only.
This avoids shell escaping issues and ensures consistent SHA references across
all comments.

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

- NEVER post comments without first extracting the correct SHA refs — stale or
  guessed SHAs cause silent failures or misplaced comments
- NEVER use shell heredocs or `echo` to build JSON payloads — backticks and
  newlines in suggestion blocks will break
- NEVER hardcode line numbers without computing them from the diff hunk headers
- NEVER omit the `-H 'Content-Type: application/json'` header on `--input`
  calls — HTTP 415 error
