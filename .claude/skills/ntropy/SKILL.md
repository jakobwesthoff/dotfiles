---
name: ntropy
description: >-
  Create, search, edit, and delete notes in ntropy Markdown vaults; create and
  manage vaults, views, and templates. Use for any task involving ntropy, a
  note vault, or .ntropy-vault files.
metadata:
  tags: ntropy, notes, markdown, vault, cli
  version-basis: authored against ntropy 1.3.0; describes the stable core model
---

# Working with ntropy

ntropy is a Markdown note-taking CLI where metadata, not folders, is the filing
system. A **vault** is a plain directory; the notes in its `all-notes/`
subdirectory are the entire database (no index, no hidden state). A note is a
Markdown file named `<ulid>-<slug>.md` with YAML frontmatter; the 26-character
ULID is its identity, `title` is required, and every frontmatter field is
instantly filterable and browsable. Organization is derived on demand: a query
language for filtering, and materialized symlink views for filesystem browsing.

## Golden rules for agents

1. **ALWAYS run non-interactively.** Pass `-n` on every command and
   `--no-edit` on `new`/`today`. Without them, on a TTY ntropy opens an
   interactive fuzzy picker or the user's `$VISUAL`/`$EDITOR` and blocks.
2. **NEVER hand-create files in `all-notes/`.** Create with
   `ntropy new --no-edit <title>` (it prints the path), then edit that file.
3. **Run `ntropy reconcile` after editing note files directly.** Direct edits
   to a title or frontmatter leave the filename slug and the views stale;
   reconcile realigns filenames, refreshes inter-note links, and re-syncs
   views. It is cheap and idempotent.
4. **Check the active vault before mutating.** `ntropy info` names the vault
   and the rule that resolved it. When in doubt, pin the vault explicitly with
   `--vault <path>`.
5. **NEVER touch derived state.** Do not write inside `by-*/` view
   directories, do not edit ntropy's managed `.gitignore` entries, and do not
   store `id` or dates in frontmatter (identity lives in the filename).
6. **Delete by ULID, with `-f`.** `delete` requires exactly one match and, in
   non-interactive mode, `--force`. Search first, then
   `ntropy delete -n -f <ulid>`.

## Do / don't

| DON'T | DO |
|-------|----|
| `ntropy new My note` — blocks in an editor | `ntropy new --no-edit My note` |
| Write a new file into `all-notes/` yourself | `path=$(ntropy new --no-edit …)`, then edit `$path` |
| `ntropy new --no-edit Q3: Planning` — `:` breaks the YAML and strands a malformed file | create with a plain title, then set `title: "Q3: Planning"` in frontmatter and reconcile |
| Rename a note file to retitle it | edit the frontmatter `title`, then `ntropy reconcile` |
| Put `id:` or `created:` in frontmatter | nothing — identity and date live in the filename ULID |
| `ntropy delete -n -f tag:old` — broad query | `ntropy delete -n -f <full-26-char-ulid>` |
| Create or edit files inside `by-*/` view directories | edit the canonical file in `all-notes/` |
| Link notes by title or view path | `[Title](<ulid>-<slug>.md)` |
| Edit a note's frontmatter and stop there | edit, then `ntropy reconcile` |

## Command reference

| Command | Purpose |
|---------|---------|
| `ntropy init [path]` | Scaffold or complete a vault; idempotent. `--set-default` records it as the global default. |
| `ntropy new --no-edit <title…>` | Create a note from a template, print its path. `-t <name>` picks `.ntropy/templates/<name>.md`. |
| `ntropy today --no-edit` | Print today's daily note path, creating it on first use each day. |
| `ntropy search -n [id\|query]` | List/filter notes as a plain table (alias `list`). No selector = all notes. Exits non-zero on no match. |
| `ntropy delete -n -f <id>` | Delete one note and refresh views. |
| `ntropy reconcile` | Realign drifted filenames, refresh links, re-sync views and `.gitignore`. |
| `ntropy view list\|add\|remove` | Manage materialized views, e.g. `view add by-status --field status`. |
| `ntropy tags -n` | Every tag with its note count — check this before inventing new tags. |
| `ntropy info` | Active vault + how it resolved, global default, vault statistics. |
| `ntropy lsp` | Language server for editors (link/tag completion, go-to-definition); not used from scripts. Editor setup lives in the ntropy README. |

Global flags on every command: `--vault <path>`, `-n`/`--non-interactive`,
`--strict` (malformed notes become errors instead of skip-warnings).

## Vault resolution (which vault will I hit?)

`--vault` > `$NTROPY_VAULT` > walk-up to the nearest ancestor with a
`.ntropy-vault` pointer file or `.ntropy/` directory (pointer wins) > the
global default. A `.ntropy-vault` file is one line pointing at a vault
elsewhere, which is how a project pins its own vault. Details and creation
recipes for global, project-local, and custom vaults:
[references/vaults.md](references/vaults.md).

## Core workflows

**Create a well-formed note:**

```bash
path=$(ntropy new --no-edit Quarterly review)
# edit "$path": fill frontmatter (title, tags, free fields) and the body
ntropy reconcile
```

Frontmatter rules, tags, inter-note links, and template authoring:
[references/writing-notes.md](references/writing-notes.md).

**Find and read notes:**

```bash
ntropy search -n 'tag:work and not status:done'   # table: ID DATE TITLE TAGS PATH
ntropy search -n 01KWVBW61WHJY7K27WNETSF641       # one note by ULID
```

Full query language (`tag:`, `field:`, `text:`, `and`/`or`/`not`), output
parsing, and exit-code recipes:
[references/querying.md](references/querying.md).

**Set up a project vault:**

```bash
ntropy init myproject/notes
echo "notes" > myproject/.ntropy-vault   # commands anywhere in the project now hit it
```

**Make a dimension browsable:**

```bash
ntropy view add by-status --field status
```

View semantics, drift, and git rules: [references/views.md](references/views.md).
