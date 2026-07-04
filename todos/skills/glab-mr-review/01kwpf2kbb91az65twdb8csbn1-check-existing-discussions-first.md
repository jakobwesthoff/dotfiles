# Workflow never reads existing MR discussions; re-runs can duplicate findings and pagination is never mentioned

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md` (Workflow, steps 1-3) and `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md` (steps 1-4)

## Current state

The workflow fetches MR metadata and the diff, then analyzes and posts. No
step reads the discussions already on the MR, so a second invocation on the
same MR (a common re-review situation) has no information about what was
already posted, by whom, or which threads are resolved. The word
"pagination" does not appear anywhere in the skill.

## Problem / opportunity

Without reading existing comments the model cannot avoid re-posting the same
finding, cannot reference or resolve prior threads, and cannot account for
author replies. When it does fetch discussions, the default API page size
silently truncates anything beyond the first 20 discussion items unless
pagination is handled.

## Grounding

- List endpoint: `GET /projects/:id/merge_requests/:merge_request_iid/discussions`
  (GitLab Discussions API, https://docs.gitlab.com/api/discussions/,
  fetched 2026-07-04; the page notes "By default, `GET` requests return 20
  results at a time because the API results are paginated").
- Pagination defaults: `per_page` "default: `20`, max: `100`"
  (https://docs.gitlab.com/api/rest/, fetched 2026-07-04).
- glab handles pagination natively: `glab api --help` (glab 1.105.0, local):
  `--paginate  Make additional HTTP requests to fetch all pages of results.`
  and `--output ndjson` for streaming large result sets.
- Native alternatives (local help, glab 1.105.0): `glab mr view <IID>
  --comments` ("Show merge request comments and activities"), with
  `--unresolved` / `--resolved` filters; `glab mr note list` (EXPERIMENTAL).
  Prior art for duplicate avoidance: `glab mr note create --unique` ("Don't
  create a note if a note with the same body already exists. Reads all merge
  request comments first").

## Proposed change

Add an early workflow step: fetch existing discussions with

```bash
glab api "projects/<ENCODED_PROJECT>/merge_requests/<IID>/discussions" --paginate
```

(or `glab mr view <IID> --comments`), and instruct the model to (a) skip
findings already raised in open threads, (b) mention pre-existing threads in
the summary only if relevant, and (c) always use `--paginate` on list
endpoints because the API returns 20 items per page by default.
