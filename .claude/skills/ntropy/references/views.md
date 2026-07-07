---
name: views
description: >-
  Materialized symlink views: grouping notes by a frontmatter field into
  browsable directories, view commands, gitignore management, and drift rules.
metadata:
  tags: views, symlinks, view-add, gitignore, reconcile, browsing
---

# Materialized views

Notes are stored flat; views are how you browse them as folders. A view pairs
a directory name with one frontmatter field and materializes the grouping as a
real symlink tree pointing back into `all-notes/`. Views are derived and
disposable: deleting one loses nothing, and a reconcile rebuilds it.

## Commands

```bash
ntropy view add by-status --field status   # define and materialize
ntropy view list -n                        # NAME FIELD table
ntropy view remove by-status               # drop the definition (directory stays)
```

There is no `view edit`; editing a view is remove + add. Definitions live in
`<vault>/.ntropy/config.toml` and travel with the vault. `init` seeds a
`by-tag` view over the `tags` field.

## Grouping semantics

For a view on field `F`, each note lands under a directory named by its `F`
value:

- A **list-valued** field (like `tags`) fans the note out into every value it
  holds; it appears in several leaves at once.
- A `/` inside a value nests subdirectories: `tags: [programming/rust]` puts
  the note under `by-tag/programming/rust/`.
- Grouping values are **normalized** (lowercased, slugified), so `In Progress`
  and `in-progress` land in the same `in-progress/` directory.
- A note with **no value** for the field is simply absent from that view.

Each leaf is a relative symlink named `<date>-<slug>.md` (creation date derived
from the ULID), so the whole vault stays relocatable:

```
by-status/in-progress/2026-07-06-refactor-the-parser.md
  -> ../../all-notes/01KWVBW61WHJY7K27WNETSF641-refactor-the-parser.md
```

Two notes colliding on `<date>-<slug>` in one group get a short ULID-derived
tail appended to disambiguate.

## Freshness and drift

Views refresh automatically after every ntropy mutation (`new`, `delete`, edits
made through ntropy's own editor flow). They do NOT see direct file edits: if
you change a note's frontmatter with your own tools, run `ntropy reconcile` to
re-sync every view (see [writing-notes.md](writing-notes.md)). If view contents
look wrong, reconcile before investigating anything else.

## Rules

- **NEVER create, edit, or delete files inside a view directory.** The leaves
  are derived symlinks; the canonical file lives in `all-notes/`. Anything you
  place in a view tree can be pruned by the next sync.
- **DO NOT commit view directories.** ntropy maintains the vault's root
  `.gitignore` with one managed, comment-marked entry per view, added on
  `view add` and pruned on `view remove`; your own lines are never touched.
- **ntropy never deletes a directory.** After `view remove` the stale tree
  stays on disk (and, no longer ignored, shows up in `git status`); the command
  reports it so you can `rm -r` it yourself.
- View names must not collide with the reserved names (`all-notes`, `.ntropy`,
  `.gitignore`) or an existing view.

## View or query?

Everything a view can group by, a query can filter by without one:
`ntropy search -n status:done` needs no `by-status` view. Add a view when the
user will browse that dimension repeatedly through the filesystem or an editor;
reach for [querying](querying.md) for one-off lookups. As an agent you rarely
need views for your own work — queries are the programmatic path.
