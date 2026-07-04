# Wording and formatting fixes (grouped minor issues)

**Skill**: glab-mr-review

All quotes read from the skill files on 2026-07-04.

## 1. Malformed code span in SKILL.md step 6

**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, step 6:

> Include ````suggestion:-N+M` blocks for concrete fix proposals.

Four backticks open the span, one closes it — this renders broken. Should be
a normal single-backtick code span around `suggestion:-N+M`.

## 2. "Decision tree" heading names a lookup table

**File**: SKILL.md, "## Decision tree". The section is a two-row
task-to-reference table, not a decision tree. Rename to "Reference files" or
"Additional resources" (the pattern used in the official skills docs,
https://code.claude.com/docs/en/skills, "Additional resources" example).

## 3. Imprecise success check "returns a `discussion.id`"

**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/review-workflow.md`, step 8:

> Verify each returns a `discussion.id` in the response.

There is no `discussion` wrapper key. The endpoint returns `201 Created` and
the discussion object itself, whose top-level fields include `id`,
`individual_note`, and `notes[]` (GitLab Discussions API, "Create new
merge request thread" response, https://docs.gitlab.com/api/discussions/,
fetched 2026-07-04). Reword to: "Verify each response is `201` and contains
a top-level `id`."

## 4. Section titled "Project ID Encoding" is about path encoding

**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, heading "Project ID Encoding". The content
encodes the project *path*; numeric IDs never need encoding. Rename to
"Project path encoding" (see the separate todo on using the numeric
`project_id` instead).

## 5. Redundant `--method GET`

**Files**: SKILL.md step 2, gitlab-api-comments.md "Required SHA
References", review-workflow.md step 2. `glab api --help` (glab 1.105.0,
local): "The default HTTP request method is `GET` when no parameters are
added". The `--method GET` flag on the SHA-extraction call is noise; drop it
or keep it consciously (it is harmless but suggests the flag is required).

## 6. Real internal project path used as example in a public repo

**File**: gitlab-api-comments.md, "Project ID Encoding":

> `ekkogmbh/service-php-eslmanager` -> `ekkogmbh%2Fservice-php-eslmanager`

The dotfiles repo is public (`git remote -v`:
`git@github.com:jakobwesthoff/dotfiles.git`), and this publishes an
internal-looking GitLab project path. Decide whether that is acceptable; if
not, replace with a neutral placeholder like `acme/service-api` (which also
demonstrates the encoding equally well).
