# Draft Notes API not covered: no way to stage a whole review and publish it atomically

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md` (workflow steps 6-7) and `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md` (whole file)

## Current state

The skill posts each approved inline comment immediately as a live discussion
(`POST .../discussions`) and then a live summary note. Comments become
visible to everyone one by one as they are posted. There is no mention of
GitLab's Draft Notes API.

## Problem / opportunity

GitLab has a first-class "pending review" mechanism: draft notes are visible
only to their author until published, and can be published all at once. Using
it would make the review appear atomically (like a GitHub PR review) instead
of trickling in, and a half-finished posting run (e.g. one payload gets a 500)
would not leave a partial public review. This is a significant missing
capability for a review skill.

## Grounding

GitLab Draft Notes API (https://docs.gitlab.com/api/draft_notes/, fetched
2026-07-04), available on Free/Premium/Ultimate tiers:

- Create: `POST /projects/:id/merge_requests/:merge_request_iid/draft_notes`.
  Required body parameter is `note` (string, "The content of a note") — NOT
  `body` as in the Discussions API. Optional: `position` (same hash as the
  Discussions API: `base_sha`, `head_sha`, `start_sha`, `position_type`
  required; `new_path`/`old_path` required for text; `new_line`, `old_line`,
  `line_range` optional), `in_reply_to_discussion_id`, `resolve_discussion`,
  `commit_id`.
- Publish one: `PUT /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id/publish`.
- Publish all: `POST /projects/:id/merge_requests/:merge_request_iid/draft_notes/bulk_publish`
  ("Publishes all pending notes belonging to the current user").
- List: `GET .../draft_notes`; delete: `DELETE .../draft_notes/:draft_note_id`.
- Draft notes "remain visible only to their author until published".

## Proposed change

Add Draft Notes coverage, either as the default posting mechanism or as a
documented alternative in gitlab-api-comments.md:

1. Post each approved inline comment as a draft note (payload key `note`
   instead of `body`, same `position` hash).
2. After all drafts are created, publish atomically via `bulk_publish`.
3. Call out the `note` vs `body` key difference explicitly, since the rest of
   the skill uses `body` and this is an easy silent mistake.
4. Optionally mention `DELETE .../draft_notes/:id` as the escape hatch if the
   user aborts before publishing.

## Addition (second pass)

Verified against GitLab source `lib/api/draft_notes.rb` (master, fetched
2026-07-04):

- The create endpoint declares `requires :note, type: String` — confirms the
  `note`-not-`body` claim above at source level. The `position` param block
  is identical to the Discussions API's (same required SHAs/position_type,
  same optional `line_range` structure).
- `bulk_publish` takes three optional parameters beyond the path params, all
  currently ABSENT from the REST docs page
  (https://docs.gitlab.com/api/draft_notes/, fetched 2026-07-04 — it
  documents only `id` and `merge_request_iid`):
  - `reviewer_state` (values `requested_changes`, `reviewed`): "Set reviewer
    review state after publishing. Does not record a formal approval".
  - `note` (string): "Summary note body to post on the merge request" — the
    endpoint publishes all drafts AND posts the summary note in one call,
    which maps 1:1 onto this skill's inline-comments-plus-summary output.
  - `internal` (boolean, default false): makes the summary note internal.

  Because these are undocumented and only verified on master, treat them as
  a bonus for current GitLab.com; older self-hosted instances may ignore or
  reject them. The documented baseline (create drafts, then plain
  `bulk_publish`, then POST the summary via the Notes API) works without
  them.
