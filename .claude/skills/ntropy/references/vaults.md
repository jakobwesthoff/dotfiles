---
name: vaults
description: >-
  Vault anatomy, how ntropy resolves the active vault, and recipes for creating
  global, project-local, and custom vaults, including .ntropy-vault pointer files.
metadata:
  tags: vault, init, resolution, pointer-file, configuration, git
---

# Vaults

A vault is an ordinary directory. There is no database and no index: the
Markdown files inside it are the single source of truth, and every command
re-reads them fresh.

## Anatomy

`ntropy init <path>` scaffolds this structure (idempotent — it creates what is
missing and never touches what exists). Name the target with the positional
path; passing both a path and `--vault` to `init` is rejected as a conflict:

```
<vault>/
├── all-notes/            # canonical notes, <ulid>-<slug>.md — the source of truth
├── by-tag/               # seeded materialized view (symlinks, derived, disposable)
├── .gitignore            # auto-managed: ignores the view directories
└── .ntropy/              # the only reserved directory
    ├── config.toml       # per-vault view definitions
    └── templates/        # default.md and today.md, plus your own
```

Only top-level `*.md` files in `all-notes/` are notes. Subdirectories and
non-`.md` files there are ignored, so images and attachments can live next to
the notes.

## How the active vault is resolved

Every command operates on exactly one vault, resolved in this order:

1. `--vault <path>` (global flag on every command)
2. `$NTROPY_VAULT`
3. Walk up from the current directory to the nearest ancestor holding a
   `.ntropy-vault` pointer file or a `.ntropy/` directory. Nearest wins; a
   pointer beats a `.ntropy/` in the same directory.
4. The global default vault (recorded by `ntropy init --set-default`).

Check what resolved, and why, with `ntropy info`. The first line names the
active vault and the rule that selected it:

```
Active vault:  /Users/you/project/notes (via pointer file /Users/you/project/.ntropy-vault)
Default vault: /Users/you/notes
```

Run `ntropy info` FIRST whenever it is unclear which vault a command will hit.
Creating notes into the wrong vault is the main failure mode this prevents.

## Creating vaults

### Global default vault

```bash
ntropy init ~/notes --set-default
```

`--set-default` records the vault as the global fallback in the OS config file
(`~/.config/ntropy/config.toml` on Linux,
`~/Library/Application Support/ntropy/config.toml` on macOS), a single
`default_vault = "..."` line. Without the flag, `init` never touches global
config.

### Project-local vault

Keep the vault in a subdirectory and drop a pointer file at the project root so
every command run anywhere inside the project resolves to it:

```bash
ntropy init myproject/notes
echo "notes" > myproject/.ntropy-vault
```

The pointer file is a single line: a path relative to the pointer file's own
directory, an absolute path, or a `~` path. A broken pointer is a hard error,
never a silent fall-through to the default.

Initializing the project root itself as the vault also works (`ntropy init .`),
but then `all-notes/` and the view directories sit next to the project's own
files. Prefer the subdirectory-plus-pointer layout.

### Custom / external vault

For a vault that no pointer or default reaches, pass it explicitly:

```bash
ntropy --vault /path/to/vault search -n tag:work    # one command
export NTROPY_VAULT=/path/to/vault                  # a whole session
```

A pointer file can also target an external vault (`echo "~/team-vault" >
.ntropy-vault`), sharing one vault across several projects.

## Configuration files

- **Global** `config.toml`: only `default_vault`. Written by
  `init --set-default`; rarely edited by hand.
- **Per-vault** `<vault>/.ntropy/config.toml`: the view definitions
  (`[[view]]` tables with `name` and `field`), so views travel with the vault.
  Manage it through `ntropy view add|remove|list`, not by hand — the CLI also
  keeps the vault's `.gitignore` and the materialized trees in sync, which a
  hand edit does not (a hand edit needs a follow-up `ntropy reconcile`).

Templates are plain files under `<vault>/.ntropy/templates/`, not config. See
[writing-notes.md](writing-notes.md).

## Reserved names

Inside a vault, `all-notes`, `.ntropy`, and `.gitignore` are reserved, as is
every configured view name. `.ntropy-vault` is reserved as the pointer-file
name. MUST NOT create your own files or directories under these names.

## Vaults under git

A vault is plain files, so version it directly: `git init` inside it and commit
notes like any text. ntropy maintains the vault's root `.gitignore` so the
derived view directories stay untracked; it marks its own entries with a
comment and never touches lines you add yourself. DO NOT commit view
directories and DO NOT remove the managed ignore entries.

## Strictness and malformed notes

Malformed notes (no `title`, bad filename) are skipped with a stderr warning by
default. Pass `--strict` to turn those warnings into hard errors — useful as a
vault health check:

```bash
ntropy search -n --strict > /dev/null   # exits non-zero if any note is malformed
```

(An empty vault also exits non-zero, since a no-match listing does; check
stderr for `error:` versus the no-match message when it matters.)
