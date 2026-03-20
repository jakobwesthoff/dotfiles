---
name: modules-and-imports
description: >-
  File splitting with mod and import — submodule isolation, file resolution,
  scoping rules, and multi-file project organization patterns.
metadata:
  tags: modules, imports, mod, submodules, organization, namespaces
---

## `import` — Flat File Inclusion

Merges another file's recipes, variables, and settings into the current scope:

```just
import 'helpers.just'

build: lint
  cargo build
```

- Path is relative to the importing file, absolute, or `~/`-prefixed.
- Imports are recursive (imported files can import others).
- Duplicate imports of the same file are OK (1.37.0).
- Order-independent: imported content can reference things defined later.

### Optional import

```just
import? 'local-overrides.just'   # no error if missing
```

### Override rules

When duplicates exist (requires `allow-duplicate-recipes`/`allow-duplicate-variables`):
- **Shallower** definitions override deeper ones.
- At the **same depth**, earlier imports win.
- Within a single file, later definitions override earlier ones.

## `mod` — Submodule Declarations

Creates an **isolated** namespace. Unlike `import`, submodule recipes,
variables, and settings are separate from the parent.

```just
mod backend
mod frontend
```

### Invoking submodule recipes

```console
$ just backend build        # subcommand style
$ just backend::build       # path style
```

### File resolution order

When declaring `mod foo`, `just` searches for:

1. `foo.just`
2. `foo/mod.just`
3. `foo/justfile` (any capitalization)
4. `foo/.justfile` (any capitalization)

### Explicit path

```just
mod foo 'custom/path.just'
mod foo 'custom/directory/'    # looks for mod.just/justfile inside
```

### Optional module

```just
mod? foo                      # no error if source file missing
```

Multiple `mod?` with the same name but different paths are allowed — at most
one may resolve:

```just
mod? platform 'platform/linux.just'
mod? platform 'platform/macos.just'
```

## Scoping Rules

Submodules are **fully isolated**:

- Variables in a submodule are NOT accessible outside it.
- Parent variables are NOT accessible inside a submodule.
- Each module has its own independent settings.
- Dotenv loading happens ONLY at the root, but loaded env vars are
  available in all submodules.

### Working directory

Submodule recipes run with CWD set to the **submodule source file's
directory**, not the root justfile directory. Use `[no-cd]` to use the
invocation directory instead.

### File path functions in module context

| Function | In root | In submodule |
|----------|---------|--------------|
| `justfile()` | root path | **still root** path |
| `justfile_directory()` | root dir | **still root** dir |
| `source_file()` | root path | submodule file path |
| `source_directory()` | root dir | submodule file dir |

Use `source_directory()` inside modules for portable relative paths:

```just
# tools/mod.just
build:
  {{source_directory()}}/scripts/compile.sh
```

## Doc & Group on Modules

```just
# Database management utilities
[group("infrastructure")]
mod db
```

The comment and `[group]` affect how the module appears in `just --list`.
`[doc("text")]` overrides the comment.

## Practical Patterns

### Domain-based split

```
justfile
backend/mod.just
frontend/mod.just
infra/mod.just
```

```just
mod backend
mod frontend
mod infra
```

### Shared utilities via import

Submodules can't see parent variables. When sharing is needed, each module
imports the same file:

```just
# shared.just
REGISTRY := "ghcr.io/myorg"
```

```just
# backend/mod.just
import '../shared.just'

push:
  docker push {{REGISTRY}}/backend
```

### Platform-specific optional modules

```just
mod? platform 'platform/linux.just'
mod? platform 'platform/macos.just'
mod? platform 'platform/windows.just'
```

Only the existing file loads.

## Anti-Patterns

NEVER expect parent variables to be visible inside a submodule — they are
isolated. Use `import` if sharing is needed.

NEVER put dotenv settings in submodules — they are ignored. Only root
justfile dotenv settings are honored.

NEVER use `justfile_directory()` inside a submodule expecting the module's
directory — it always returns the root. Use `source_directory()` instead.

NEVER depend on sibling modules from within a submodule — a recipe in
`api/mod.just` cannot reference `db::migrate` because `db` is not in `api`'s
scope. Cross-module dependencies only work from the scope where both modules
are declared (typically the root justfile).
