---
name: writing-notes
description: >-
  How to create and author well-behaving ntropy notes: the creation workflow,
  frontmatter rules, tags, inter-note links, templates, and when to reconcile.
metadata:
  tags: notes, frontmatter, tags, links, templates, reconcile, authoring
---

# Writing notes

A note is a Markdown file with a YAML frontmatter block, stored flat as
`all-notes/<ulid>-<slug>.md`. The leading 26-character ULID is the note's
identity; the slug is a readable echo of the title. Filing happens through
metadata, not folders: put a note's dimensions (tags, status, project, …) in
frontmatter and let queries and views do the organizing.

## Creating a note (the only correct way)

Always create through `ntropy new` so the ULID and filename are right, then
edit the file it prints:

```bash
path=$(ntropy new --no-edit Refactor the parser)   # trailing args join into the title
# now write frontmatter/body into "$path" with your file tools
ntropy reconcile                                    # realign filename + views after direct edits
```

`--no-edit` (alias `--print`) creates the note and prints its path instead of
opening an editor. This is the agent path; the editor flow is for humans.

**FORBIDDEN: hand-creating files in `all-notes/`.** You would have to invent a
ULID; a wrong or duplicate one corrupts note identity. Create via `ntropy new`,
then edit.

**MUST run `ntropy reconcile` after directly editing a note's frontmatter or
title.** ntropy only realigns automatically when it launched the editor itself.
After out-of-band edits, the filename slug can drift from the title and the
materialized views go stale until reconcile runs. It is cheap and idempotent;
when in doubt, run it.

### YAML-unsafe titles

`ntropy new` substitutes the title verbatim into the template's
`title: {{title}}` line. A title that breaks YAML there makes `new` fail — and
it can leave the broken note file behind in `all-notes/`, which every later
command then skips with a warning until you delete or repair it. This bites on
`: ` inside the title and on a leading YAML syntax character (`[`, `{`, `#`,
`-`, `&`, `*`, `"`, `'`):

```bash
ntropy new --no-edit Q3: Planning kickoff      # FAILS: invalid YAML
ntropy new --no-edit "[draft] roadmap"          # FAILS: invalid YAML
```

For such titles, create with a plain provisional title, then set the real one
as a quoted YAML string and reconcile:

```bash
path=$(ntropy new --no-edit q3 planning kickoff)
# edit "$path": set the frontmatter title to
#   title: "Q3: Planning kickoff"
ntropy reconcile
```

The same rule applies whenever you write frontmatter by hand: quote any YAML
value that contains `: ` or starts with YAML syntax. Interior quotes in an
otherwise plain title (`He said "go"`) are fine unquoted.

### Retitling a note

Never rename the file. Edit the frontmatter `title`, then run
`ntropy reconcile`: it renames the file to the new slug (the ULID stays, so
identity and inbound links survive) and rewrites the slug portion of links in
other notes.

## Frontmatter rules

```markdown
---
title: Q3 Planning
tags: [work, planning, area/roadmap]
status: in progress
due: 2026-07-01
---
# Q3 Planning

Body is ordinary Markdown.
```

- **`title` is required** and canonical: full case, punctuation, Unicode. A
  note without one is malformed (skipped with a warning; an error under
  `--strict`).
- **`tags` is a flat YAML list of strings.** A `/` inside a tag denotes
  hierarchy: `area/roadmap` is one tag with two levels, understood by both
  queries and views. Tags are lowercase-normalized, so `Rust` and `rust` are
  the same tag. Never nest YAML structures inside `tags`.
- **Every other field is free** (`status`, `project`, `author`, anything) and
  becomes queryable and view-groupable just by existing. Unknown fields are
  preserved untouched when ntropy rewrites a note.
- **NEVER store `id`, `created`, or `modified` in frontmatter.** Identity is
  the filename ULID; the creation date is derived from it. Duplicating them
  creates state that can drift.

For clean vaults, reuse field names and values consistently: `field:value`
queries match exactly (case-sensitive), and views group per distinct value, so
`status: done` and `status: Done` behave as different query values even though
a view folds them into one normalized directory. Pick one spelling and stick to
it. Before inventing a new tag or field value, check what the vault already
uses: `ntropy tags -n` lists every tag with its count.

## Linking between notes

Links are ordinary Markdown links whose target is the note's filename, nothing
custom:

```markdown
See [the Q3 plan](01j8za2abcdefghjkmnpqrstvw-q3-planning.md) for the numbers.
```

Get the filename from a search (`ntropy search -n tag:planning`, PATH column)
and use its basename. A link is recognized by its leading 26-character ULID, so
it survives retitles: `ntropy reconcile` rewrites the slug portion of stale
link targets after a rename (links inside fenced or inline code are left
alone). DO NOT link by title or by relative folder paths into views.

## Templates

Every `ntropy new` stamps a note from a template in
`<vault>/.ntropy/templates/`; the filename minus `.md` is the template name:

```bash
ntropy new --no-edit Standup --template meeting   # uses .ntropy/templates/meeting.md
ntropy new --no-edit Some thought                 # uses default.md
```

A named template that does not exist is an error, never a silent fallback.

Author a template by writing the file; placeholders are substituted at creation
time and anything unrecognized is left untouched:

| Placeholder | Becomes |
|-------------|---------|
| `{{title}}` | the title passed to `new` |
| `{{id}}`    | the note's ULID |
| `{{date}}`  | creation date, `YYYY-MM-DD`, local time |
| `{{slug}}`  | the slugified title |

```markdown
<!-- .ntropy/templates/meeting.md -->
---
title: {{title}}
date: {{date}}
tags: [meeting]
status: notes
---
# {{title}}

## Attendees

## Notes

## Action items
```

Keep `title: {{title}}` in custom templates. The filename slug is derived from
the title passed on the command line, so a template that hardcodes a different
title creates immediate slug drift that the next reconcile has to rename away.

## Daily notes

`ntropy today --no-edit` prints the path of today's note, creating it from
`.ntropy/templates/today.md` on first use each day (the note is identified by
its title being today's date). Shape daily notes by editing that template. It
must exist; a vault predating it just needs `ntropy init <vault>` re-run, which
seeds missing pieces without touching existing ones.

## Attachments

Non-`.md` files and subdirectories inside `all-notes/` are ignored by ntropy,
so images and other attachments live right next to the notes and are referenced
with ordinary relative Markdown syntax (`![diagram](diagram.png)`). Only
inter-note links get the ULID-based refresh treatment.

## Slug and normalization facts

Knowing what filenames will look like helps you predict paths: slugs are
lowercase ASCII with `-` for whitespace, German-aware transliteration
(`ä→ae`, `ö→oe`, `ü→ue`, `ß→ss`), other non-ASCII best-effort transliterated or
dropped, capped near 72 characters, and `untitled` when nothing survives. The
full title always remains in frontmatter, so never shorten a title for the
filename's sake. Because the millisecond-precise ULID leads every filename, a
plain lexical sort of `all-notes/` is chronological.

## Well-behaved note checklist

- Created via `ntropy new --no-edit`, never hand-placed in `all-notes/`.
- Frontmatter has `title`; `tags` is a flat string list; no `id`/date fields.
- YAML values containing `: ` or starting with YAML syntax are quoted.
- Field names and values reused consistently with the rest of the vault.
- Links target `<ulid>-<slug>.md` filenames.
- `ntropy reconcile` run after any direct edit to frontmatter or title.
