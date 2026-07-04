# The two reference files contradict each other on what bad SHAs cause (400 vs silent failure), and neither matches the documented behavior

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, section "Required SHA References"
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, section "Anti-patterns"

## Current state

gitlab-api-comments.md:

> They MUST match the current head of the MR branch — stale SHAs cause 400
> errors.

review-workflow.md:

> NEVER post comments without first extracting the correct SHA refs — stale
> or guessed SHAs cause silent failures or misplaced comments

One file claims a hard 400, the other claims silent failure/misplacement.
Both are presented as fact.

## Problem / opportunity

An LLM handling a posting error will consult these rules. Contradictory
failure-mode descriptions make diagnosis unreliable (e.g. on a 500 the model
may conclude the SHAs are fine because "stale SHAs cause 400").

## Grounding

- GitLab Discussions API docs (https://docs.gitlab.com/api/discussions/,
  fetched 2026-07-04): "If you specify incorrect `base`, `head`, `start`, or
  `SHA` parameters, you might run into the bug described in issue #296829."
- Issue gitlab-org/gitlab#296829 (fetched 2026-07-04): with mismatched
  base_sha/head_sha/start_sha the API returns **500 Internal Server Error**
  ("Failed to find diff line for: <file>, old_line: N, new_line: N",
  `DiffNote::NoteDiffFileCreationError`), and in other cases the comment is
  created but renders as a "download" link instead of inline code. Issue is
  still open.

So the documented outcomes for wrong SHAs are 500 errors or a mis-rendered
comment; neither file's blanket claim is accurate on its own.

## Proposed change

Unify both files on one grounded statement, e.g.: "Wrong or stale SHAs fail
unpredictably: GitLab may return 500 (`Failed to find diff line ...`) or
create a broken comment (rendered as an attachment link instead of an inline
thread) — see gitlab-org/gitlab#296829, referenced from the Discussions API
docs. Always fetch `diff_refs` immediately before posting; never reuse SHAs
from an earlier session." Remove the specific "400" claim unless a source for
it is found.

## Correction (second pass)

The proposed change above says to remove the "400" claim "unless a source
for it is found". A source exists, so the unified statement should keep 400
for one specific case instead of dropping it. GitLab's own request specs
(fetched 2026-07-04) show 400 Bad Request when the position's line values
cannot be resolved against the diff:

- `spec/support/shared_examples/requests/api/diff_discussions_shared_examples.rb`,
  context "when position is invalid": `new_line: '100000'` (not plausible)
  and `new_line: '588440f6...'` (garbage) both expect
  `have_gitlab_http_status(:bad_request)`.
- `spec/requests/api/discussions_spec.rb`, context "when position is for a
  previous commit on the merge request" also expects `:bad_request`.
- Mechanism: `app/models/diff_note.rb` validates `line_code` presence for
  text notes; `line_code` is computed server-side from the position
  (`set_line_code`), so an unresolvable line yields a validation error,
  which Grape renders as 400. Incomplete positions (missing line fields)
  also 400 via `positions_complete` ("position is incomplete").

Refined unified statement for the skill: unresolvable line numbers or
incomplete positions fail with 400; mismatched/incoherent
`base_sha`/`head_sha`/`start_sha` combinations fail with 500
(`Failed to find diff line for ...`, issue gitlab-org/gitlab#296829) or
produce a broken comment rendered as an attachment link. Both failure
classes are avoided the same way: fetch `diff_refs` fresh and compute lines
from the current diff.
