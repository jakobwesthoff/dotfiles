---
name: querying
description: >-
  The ntropy query language (tag:, field:, text:, and/or/not), how search and
  delete select notes, plain-output parsing, and exit-code recipes for scripting.
metadata:
  tags: search, query, dsl, delete, scripting, exit-codes, output
---

# Querying and scripting

`ntropy search` (alias `list`) is the single browse / filter / full-text /
open entry point. Filtering and full-text search are one mechanism: a query
expression evaluated in a single pass over `all-notes/`. `delete` takes the
same selector.

The selector is optional and joined from all trailing arguments:

- **omitted** — all notes
- **a full 26-character ULID** — exactly that note
- **anything else** — a query expression

## The query language

Combine predicates with `and`, `or`, `not`; precedence is `not` > `and` > `or`;
parentheses override. Values are bare words (Unicode letters, digits, `/`, `_`,
`-`) or double-quoted strings for anything with spaces or regex metacharacters.

```bash
ntropy search -n tag:work and not status:done
ntropy search -n 'status:"in progress" or tag:urgent'
ntropy search -n '(tag:work or tag:side-project) and not status:done'
ntropy search -n borrow checker            # bare words = full-text over the body
```

Quote the whole query for the shell whenever it contains `(`, `)`, or double
quotes.

### Predicate semantics

- **`tag:Q`** — segment sub-path match, case-insensitive. `Q` and the note's
  tags are split on `/`; `Q` matches when its segments appear as a contiguous
  run inside a tag's segments. `tag:programming` matches `programming`,
  `programming/rust`, and `area/programming`; `tag:programming/rust` matches
  any tag containing that consecutive chain.
- **`field:value`** — frontmatter equality for scalars, membership for list
  fields. Exact and case-sensitive: `status:Done` does not match `status:
  done`. Quote multi-word values: `status:"in progress"`.
- **`text:pattern`** (and bare words / bare quoted phrases) — a regex over the
  note body, smart-case: all-lowercase patterns match case-insensitively, one
  literal uppercase character makes the match case-sensitive. An invalid regex
  is a query error.

There are no comparison operators (`>`, `<`, date ranges) in the language.

## Non-interactive output

ALWAYS pass `-n` (or pipe the output; both suppress the picker and the
editor). The plain table is one note per line, newest first, space-aligned
columns padded to the widest cell, with an uppercase header row:

```
ID                          DATE        TITLE                TAGS                   PATH
01KWVBW61WHJY7K27WNETSF641  2026-07-06  Refactor the parser  work,programming/rust  /…/all-notes/01KWVBW61WHJY7K27WNETSF641-refactor-the-parser.md
```

`tail -n +2` drops the header. Columns are separated by runs of two or more
spaces (the last column is unpadded), so fields that themselves contain single
spaces stay parseable:

```bash
# All matching IDs (first column is a fixed-width 26-char ULID):
ntropy search -n tag:work | tail -n +2 | awk '{print $1}'

# The file path of one note by ULID (last column):
ntropy search -n 01KWVBW61WHJY7K27WNETSF641 | tail -n +2 | awk -F'  +' '{print $NF}'
```

The `awk -F'  +'` split misparses a title containing two consecutive spaces; if
that matters, resolve the path by ULID glob instead:
`<vault>/all-notes/<ulid>-*.md`. `tags` and `view list` print the same style of
headed, space-aligned table.

## Exit codes

A `search` that matches nothing prints `No notes matched your search criteria.`
to stderr and exits non-zero; matches exit zero. Branch on existence without
parsing anything:

```bash
if ntropy search -n tag:urgent > /dev/null 2>&1; then
  echo "something is on fire"
fi
```

This includes the no-selector form: listing an empty vault exits non-zero too.
Treat exit 1 from `search` as "nothing matched", not as a command failure;
genuine failures (unresolvable vault, invalid query/regex) print an `error:`
line to stderr instead of the no-match message.

## Deleting

```bash
ntropy delete -n -f 01KWVBW61WHJY7K27WNETSF641
```

`delete` must resolve to **exactly one** note: an ambiguous query fails with
the candidate list and a non-zero exit. Non-interactive deletion requires
`--force`/`-f` (there is no prompt to answer), so the safe agent pattern is:
`search -n` first, confirm the single intended ULID, then `delete -n -f
<ulid>`. NEVER delete by a broad query; pass the ULID.

Deleting removes the canonical file and refreshes the views.
