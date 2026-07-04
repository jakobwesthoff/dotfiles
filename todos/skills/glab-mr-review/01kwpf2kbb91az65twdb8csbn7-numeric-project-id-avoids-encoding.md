# The numeric project ID avoids URL-encoding entirely and is already available from step 1

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, section "Project ID Encoding"; SKILL.md "Critical rules" ("URL-encode project paths")

## Current state

The skill presents URL-encoding the project path (`group/project` ->
`group%2Fproject`) as the only way to address the project in API paths, and
elevates it to a Critical rule. Manual `%2F` encoding is an easy place for a
model to slip (forgetting one slash in `group/sub/project`, double-encoding).

## Problem / opportunity

Every affected endpoint's `:id` segment also accepts the numeric project ID,
which needs no encoding, and the workflow already has that number in hand
after fetching the MR as JSON.

## Grounding

- GitLab API parameter definition: `id` is "integer or string: Project ID or
  URL-encoded path" (Draft Notes API parameter table,
  https://docs.gitlab.com/api/draft_notes/, fetched 2026-07-04; the
  Discussions and Notes endpoints use the same `POST
  /projects/:id/merge_requests/:merge_request_iid/...` path parameter).
- Live read-only verification (2026-07-04): `glab mr view 1000 --repo
  gitlab-org/cli --output json` returns `project_id: 34675721` on the MR
  object.

## Proposed change

In the "Project ID Encoding" section, document the numeric alternative:
take `project_id` from the `glab mr view --output json` response (or the
`glab api .../merge_requests/<IID>` response) and build API paths as
`projects/<project_id>/merge_requests/<IID>/...`, no encoding needed. Keep
the `%2F` rule for cases where only the path is known, and mention `:fullpath`
placeholder substitution when running inside the repo (see the todo about
the nonexistent `--repo` flag on `glab api`).
