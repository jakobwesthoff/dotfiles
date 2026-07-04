# Steps 1 and 2 can be one call: `glab mr view --output json` already returns `diff_refs`

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, steps 1-2
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, steps 1-2
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, section "Required SHA References"

## Current state

The workflow fetches MR metadata with `glab mr view <IID> --repo <group/project>`
(text output) and then makes a second, separate call to get the SHAs:

```bash
glab api "projects/<ENCODED_PROJECT>/merge_requests/<IID>" --method GET
```

## Problem / opportunity

`glab mr view` supports `--output json` and its JSON payload contains the
full `diff_refs` object, so the dedicated `glab api` GET (and the manual
project-path URL-encoding it requires) is redundant. One command yields
title/author/state AND `base_sha`/`head_sha`/`start_sha`.

## Grounding

- `glab mr view --help` (glab 1.105.0, local, 2026-07-04): `-F --output
  Format output as: text, json. (text)`; also `--jq  Filter JSON output
  with a jq expression.`
- Live read-only verification (2026-07-04):
  `glab mr view 1000 --repo gitlab-org/cli --output json` returned
  `diff_refs` with all three keys:

  ```
  has diff_refs: True
  diff_refs: {
    "base_sha": "601b6b458491a11e1aad2aba3e3e1145d41a79a9",
    "head_sha": "1e3cc3dd1c248ae5f67ad3f45693f5d34f8f8322",
    "start_sha": "141061924f79a28286c86e1088b858ad3789e12c"
  }
  ```

## Proposed change

Replace the separate SHA-extraction step with:

```bash
glab mr view <IID> --repo <group/project> --output json \
  --jq '{title, author: .author.username, state, diff_refs}'
```

(or plain `--output json` parsed via Python). Update SKILL.md steps 1-2,
review-workflow.md steps 1-2, and the "Required SHA References" extraction
snippet accordingly. The `glab api` GET can stay as a fallback note, but the
primary path should be the single call.
