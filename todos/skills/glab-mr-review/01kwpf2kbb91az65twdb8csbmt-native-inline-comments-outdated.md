# Outdated claim: `glab mr` now supports inline diff comments natively (`glab mr note create --file/--line`)

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, section "Overview"

## Current state

> `glab mr` does not support inline diff comments natively. Use `glab api` to
> call the GitLab Discussions and Notes REST endpoints directly.

## Problem / opportunity

The claim is outdated for the installed glab. `glab mr note create` can place
diff comments on files, single lines, line ranges, and removed lines, and can
reply to existing discussions. It targets the latest diff version itself, so
for simple cases it removes the entire manual SHA-extraction and
line-counting burden. The skill should present it as an alternative with its
caveats, instead of asserting it does not exist.

## Grounding

`glab mr note create --help` (glab 1.105.0, local, 2026-07-04):

- `--file  File path for a diff comment, like <path/to/file>. Targets the
  latest merge request diff version.`
- `--line  Line in the new version. A single line number, like 42, or a
  range, like 10:15.`
- `--old-line  Line in the old version, for commenting on a removed line.`
- `--reply  Reply to an existing discussion. Accepts a full discussion ID or
  a prefix of 8 or more characters.`
- `--unique  Don't create a note if a note with the same body already
  exists. Reads all merge request comments first.`
- `--resolvable  Create the note as a resolvable discussion thread. Set to
  false to create a non-resolvable note. (true)`
- Flag rules from help: `--line`/`--old-line` require `--file` and cannot be
  combined with each other; `--file`, `--reply`, and `--unique` are mutually
  exclusive; `--resolvable=false` cannot combine with `--reply` or `--file`.
- Message can be piped from stdin (help example: `echo "LGTM" | glab mr note
  create 123`), which sidesteps shell-escaping of suggestion blocks in `-m`.
- Caveat, quoted from help: "This feature is an experiment and is not ready
  for production use. It might be unstable or removed at any time."

## Proposed change

1. Rewrite the Overview: state that glab (>= the installed 1.105.0) has
   native but experimental inline diff comments via `glab mr note create
   --file <path> --line N` (or `--line N:M` for ranges, `--old-line N` for
   removed lines), always anchored to the latest diff version.
2. Keep the raw `glab api` Discussions route as the primary documented path,
   with the reasons the native command does not fully replace it: it is
   experimental, it cannot set both `old_line` and `new_line` together, it
   offers no draft-note staging, and it cannot pin an older diff version.
   (Each of these limits comes from the flag rules above and the absence of
   corresponding flags in the help output.)
3. If the native route is documented, recommend piping the comment body from
   a file via stdin instead of `-m` to avoid shell-escaping issues, and
   mention `--unique` as duplicate protection on re-runs.
