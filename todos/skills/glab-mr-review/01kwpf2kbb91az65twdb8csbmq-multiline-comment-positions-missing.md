# Multiline diff comments (`position[line_range]`) are not covered

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, sections "Computing Line Numbers" / "Posting Inline Comments"

## Current state

The position payload documentation only supports single-line anchors
(`new_line`/`old_line`). Multiline comments are not mentioned anywhere, even
though the skill's suggestion examples span multiple lines (a multiline
suggestion anchored to a single line works, but the comment highlight covers
one line only).

## Problem / opportunity

Review findings frequently concern a block of lines (a whole function, a
config stanza). GitLab supports anchoring a discussion to a line range, which
renders the comment attached to the full range in the diff view. A reviewer
following the skill cannot produce these.

## Grounding

GitLab Discussions API, "Create new merge request thread", parameters for
multiline comments (https://docs.gitlab.com/api/discussions/, fetched
2026-07-04):

- `position[line_range]` (hash, optional): "Line range for a multi-line diff
  note."
- `position[line_range][start][line_code]` (string, required): line code for
  the start line.
- `position[line_range][start][type]` (string, required): "Use `new` for
  lines added by this commit, otherwise `old`."
- `position[line_range][start][old_line]` / `[new_line]` (integer, optional).
- Same four fields under `position[line_range][end]`.

Line code format (same page): "A line code is of the form `<SHA>_<old>_<new>`,
like this: `adc83b19e793491b1c6ea0fd8b46cd9f32e292fc_5_5`", where "`<SHA>` is
the SHA1 hash of the filename. `<old>` is the line number before the change.
`<new>` is the line number after the change."

In Python the line code is computable as
`hashlib.sha1(new_path.encode()).hexdigest() + f"_{old_line}_{new_line}"`.

## Proposed change

Add a "Multiline comments" subsection to gitlab-api-comments.md documenting
`position[line_range]` with the start/end structure, the required `line_code`
and `type` fields, the line-code construction formula (SHA1 of the file path,
then `_<old>_<new>`), and a worked JSON example.

## Second pass grounding

The open question (top-level line fields vs `line_range`) is settled from
GitLab and glab sources (all fetched 2026-07-04):

1. **Top-level `old_line`/`new_line` remain REQUIRED when `line_range` is
   present.** GitLab source, `lib/gitlab/diff/formatters/text_formatter.rb`
   (master): `def complete? ... old_line.present? || new_line.present?` —
   `line_range` is not considered. `app/models/diff_note.rb` validates
   `positions_complete` and adds `errors.add(:position, "is incomplete")`
   when `complete?` is false, which the API surfaces as 400. So a payload
   with only `line_range` and no top-level line field is rejected.

2. **Set the top-level fields to the END line of the range.** glab's own
   implementation (`internal/commands/mr/mrutils/position.go`, identical on
   `main` and the installed `v1.105.0` tag) sets `pos.NewLine = lineEnd` and
   carries this code comment: "GitLab attaches the note at
   new_line/old_line, so those must reference the *end* of the range;
   line_range defines the highlighted span." If the end line is a context
   line, glab also sets top-level `old_line` (consistent with the
   both-fields rule for unchanged lines).

3. **Worked 201 examples exist in GitLab's own request specs.**
   `spec/requests/api/discussions_spec.rb` (master), context "when creating
   a note for multiple lines": POSTs a complete single-line text position
   merged with a `line_range` whose `start`/`end` carry `line_code`, `type`,
   and `new_line`; expects `:created`.
   `spec/support/shared_examples/requests/api/diff_discussions_shared_examples.rb`
   has a second 201 example whose `line_range` start/end carry ONLY
   `line_code` + `type` — the nested `old_line`/`new_line` are genuinely
   optional.

4. **`line_code` format confirmed, and it is Grape-optional despite the
   docs saying "required".** `lib/gitlab/git.rb`:
   `def diff_line_code(file_path, new_line_position, old_line_position)`
   returns `"#{Digest::SHA1.hexdigest(file_path)}_#{old_line_position}_#{new_line_position}"`
   (order in the string: old first, then new — matching the Python formula
   above). In `lib/api/discussions.rb` (master) every field inside
   `line_range[start]`/`line_range[end]`, including `line_code` and `type`,
   is declared `optional` at the API layer; the docs' "required" is not
   enforced there. glab even sends fabricated line codes with a `0` old
   component (`sha1(path)_0_<new_line>`, position.go `lineCode()`), so exact
   old/new numbers inside the line code are not validated server-side.
   Recommendation for the skill regardless: build line codes from the true
   old/new counter pair, which the skill has after adding the old-file
   counting rule (see the context-line todo).

No sandbox test needed; the multiline subsection can be documented from the
above.
