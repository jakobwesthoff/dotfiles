# No coverage for replying to or resolving existing discussions

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md` (no section covers this); SKILL.md "When to use" scopes the skill to reviews generally

## Current state

The skill only documents creating new discussions and one summary note.
Re-review scenarios (respond to an author's answer on a thread, resolve a
thread whose finding was addressed, reopen one) have no documented mechanics.

## Problem / opportunity

A review skill is naturally re-invoked on the same MR after the author
pushes fixes. Without these endpoints the model improvises, and the
matching native glab commands are marked experimental, so knowing both
routes matters.

## Grounding

GitLab Discussions API (https://docs.gitlab.com/api/discussions/, fetched
2026-07-04):

- Reply to a thread: `POST /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id/notes`
  with required `body`; returns 201 and the created note.
- Resolve/reopen a thread: `PUT /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id`
  with boolean `resolved` ("If true, resolve or reopen the discussion");
  returns 200 and the updated discussion.
- A plain (non-diff) thread can be created by POSTing to `.../discussions`
  with only `body` ("Create a new thread on the overview page").

`glab mr note --help` (glab 1.105.0, local, 2026-07-04) shows native
subcommands, all labelled EXPERIMENTAL: `create`, `delete <note-id>`,
`list`, `reopen <discussion-id>`, `resolve <discussion-id>`, `update
<note-id>`. Also `glab mr view` supports `--resolved` / `--unresolved`
flags ("Show only resolved/unresolved discussions (implies --comments)")
for inspecting thread state.

## Proposed change

Add a "Follow-up operations" section to gitlab-api-comments.md covering:

- Reply: `POST .../discussions/:discussion_id/notes` with `body`.
- Resolve/unresolve: `PUT .../discussions/:discussion_id` with
  `resolved=true|false` (a boolean field, postable via
  `glab api ... --method PUT --field resolved=true` since `--field` converts
  `true`/`false` to JSON booleans per `glab api --help`).
- Native alternative: `glab mr note resolve <discussion-id> <IID>` exists but
  is experimental in glab 1.105.0.
- Inspecting existing threads: `glab mr view <IID> --comments` (or
  `--unresolved`).
