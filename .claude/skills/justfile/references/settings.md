---
name: settings
description: >-
  All set directives — shell config, dotenv, export, quiet, fallback,
  positional arguments, and per-module scoping rules.
metadata:
  tags: settings, set, shell, dotenv, export, quiet, fallback, configuration
---

Settings control justfile interpretation and execution. Declared with `set`
at the top level. Boolean settings support shorthand: `set NAME` equals
`set NAME := true`.

Settings are **per-module** — a submodule's settings do not affect the root,
and vice versa. Each module's dotenv settings load that module's own
environment file; see "Dotenv Settings" below for inheritance rules.

Since 1.46.0, non-boolean settings accept expressions, but those expressions
are evaluated in a **const context**: no backticks, no function calls, and
no references to non-const variables. Referencing a variable that is
itself const (built from literals and operators) is allowed.

`set minimum-version := '1.55.0'` (1.55.0) errors if the running `just` is
older than the given version. Place it at the top of the justfile for
justfiles that rely on recent features.

## Quick Reference

| Setting | Type | Default | Purpose |
|---------|------|---------|---------|
| `allow-duplicate-recipes` | bool | `false` | Last recipe definition wins |
| `allow-duplicate-variables` | bool | `false` | Last variable definition wins |
| `default-list` | bool | `false` | Bare `just` prints the recipe list instead of running the first recipe (1.52.0) |
| `default-script` | bool | `false` | Recipes default to script recipes instead of shell recipes, unless overridden with `[shell]` (1.52.0) |
| `dotenv-load` | bool | `false` | Load `.env` file |
| `dotenv-filename` | string | — | Custom `.env` filename (searched up dirs) |
| `dotenv-path` | string | — | Exact `.env` path (errors if missing) |
| `dotenv-override` | bool | `false` | `.env` values override existing env |
| `dotenv-required` | bool | `false` | Error if `.env` not found |
| `dotenv-command` | string | — | Command whose stdout is loaded as an environment file (1.54.0) |
| `export` | bool | `false` | Export all just variables as env vars |
| `fallback` | bool | `false` | Search parent dirs for missing recipes |
| `guards` | bool | `false` | Enable `?` line sigil |
| `ignore-comments` | bool | `false` | Don't pass `#` lines to shell |
| `lazy` | bool | `false` | Skip unused variable evaluation |
| `lists` | bool | `false` | Values may be lists of strings instead of strings (1.53.0, unstable) |
| `minimum-version` | string | — | Errors if `just` is older than the given version (1.55.0) |
| `no-cd` | bool | `false` | Don't change directory when executing recipes (1.51.0) |
| `no-exit-message` | bool | `false` | Suppress recipe failure messages |
| `positional-arguments` | bool | `false` | Pass args as `$1`, `$2`, `$@` |
| `quiet` | bool | `false` | Don't echo recipe lines |
| `script-interpreter` | list | `['sh', '-eu']` | Interpreter for `[script]` recipes |
| `shell` | list | `['sh', '-cu']` | Shell for linewise recipes + backticks |
| `tempdir` | string | — | Temp dir for script/shebang recipes |
| `unstable` | bool | `false` | Enable unstable features |
| `windows-powershell` | bool | `false` | **Deprecated** — use `windows-shell` |
| `windows-shell` | list | — | Shell override for Windows only |
| `working-directory` | string | — | Working dir for recipes (relative to justfile dir) |

## Shell Configuration

```just
set shell := ["bash", "-uc"]
```

Controls linewise recipe lines and backtick evaluation. Shebang/script
recipes are NOT affected.

Common configurations:

```just
set shell := ["bash", "-uc"]
set shell := ["zsh", "-uc"]
set shell := ["fish", "-c"]
set shell := ["nu", "-c"]
set shell := ["python3", "-c"]
```

**Windows-specific override** (higher precedence than `set shell`):

```just
set windows-shell := ["pwsh", "-NoLogo", "-Command"]
```

Shell selection precedence: `--shell` CLI > `windows-shell` > `shell`.

## Dotenv Settings

Loaded variables are **shell environment variables**, NOT just
variables — access them with `$NAME` in recipes, not `{{NAME}}`.

```just
set dotenv-load

serve:
  ./server --port $SERVER_PORT
```

`dotenv-path` overrides `dotenv-filename`. `dotenv-path` errors if the
file is missing; `dotenv-filename` does not (unless `dotenv-required`).

**`dotenv-command`** (1.54.0): instead of reading an env file directly,
`just` runs the given command with the configured shell and loads its
stdout as an environment file. Useful for secret managers:

```just
set dotenv-command := 'sops -d .enc.env'
```

Submodules can load their own environment files via their own dotenv
settings (1.49.0+). Variables from environment files loaded in a parent
module are inherited by submodules; a submodule's own environment file
may override values inherited from the parent.

## Export

```just
set export

name := "world"

greet:
  echo $name    # works — exported as env var
```

**Caveat with `lazy`**: exported variables are ALWAYS evaluated even when
`set lazy` is active, because `just` cannot know when they're used by
child processes.

## Positional Arguments

```just
set positional-arguments

@foo bar:
  echo $0    # recipe name: "foo"
  echo $1    # first argument
```

Per-recipe alternative: `[positional-arguments]` attribute.

`"$@"` expands to all arguments. Useful for variadic forwarding:

```just
set positional-arguments

@test *args='':
  bash -c 'for a; do echo "- $a"; done' -- "$@"
```

## Quiet Mode

```just
set quiet
```

Suppresses echoing of all recipe lines. Override per-recipe with `[no-quiet]`.

This is different from `just --quiet` (CLI flag), which suppresses ALL
output including recipe stdout.

## Fallback

```just
set fallback
```

When a recipe isn't found, search parent directories for justfiles.
Search stops at a justfile without `set fallback`. Fallback only works
with directory-based search — `--justfile` pins to an exact file and
disables fallback.

## Lazy Evaluation (1.47.0+)

```just
set lazy

token := `expensive-credential-fetch`

deploy:
  curl -H "Bearer {{token}}" https://api.example.com

test:
  cargo test    # token is NOT evaluated
```

## Working Directory

```just
set working-directory := 'subdir'
```

Relative to the justfile directory. Per-recipe override: `[working-directory]`
attribute. `[no-cd]` ignores all working directory settings.

## Anti-Patterns

NEVER use `set windows-powershell` — it is deprecated. Use `set windows-shell`
instead.

NEVER put backticks, function calls, or references to non-const variables
in setting expressions — a setting value cannot be dynamic:

```just
# BROKEN — backticks not allowed in settings
set working-directory := `pwd`

# BROKEN — dir is non-const (built from a backtick), still rejected
dir := `pwd`
set working-directory := dir
```

For a dynamic working directory, use the per-recipe `[working-directory(expression)]`
attribute, which accepts expressions including function calls:

```just
[working-directory(justfile_directory() / 'build')]
build:
  cargo build
```

Or change directory inside the recipe body instead.
