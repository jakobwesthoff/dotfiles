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
and vice versa. Exception: dotenv loading only happens at the root.

Since 1.46.0, non-boolean settings accept expressions, but those expressions
MUST NOT contain backticks or function calls.

## Quick Reference

| Setting | Type | Default | Purpose |
|---------|------|---------|---------|
| `allow-duplicate-recipes` | bool | `false` | Last recipe definition wins |
| `allow-duplicate-variables` | bool | `false` | Last variable definition wins |
| `dotenv-load` | bool | `false` | Load `.env` file |
| `dotenv-filename` | string | — | Custom `.env` filename (searched up dirs) |
| `dotenv-path` | string | — | Exact `.env` path (errors if missing) |
| `dotenv-override` | bool | `false` | `.env` values override existing env |
| `dotenv-required` | bool | `false` | Error if `.env` not found |
| `export` | bool | `false` | Export all just variables as env vars |
| `fallback` | bool | `false` | Search parent dirs for missing recipes |
| `guards` | bool | `false` | Enable `?` line sigil |
| `ignore-comments` | bool | `false` | Don't pass `#` lines to shell |
| `lazy` | bool | `false` | Skip unused variable evaluation (unstable) |
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

Dotenv loading occurs ONLY for the root justfile. Loaded variables are
**shell environment variables**, NOT just variables — access them with
`$NAME` in recipes, not `{{NAME}}`.

```just
set dotenv-load

serve:
  ./server --port $SERVER_PORT
```

`dotenv-path` overrides `dotenv-filename`. `dotenv-path` errors if the
file is missing; `dotenv-filename` does not (unless `dotenv-required`).

Dotenv settings in submodules are **ignored**.

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
Search stops at a justfile without `set fallback`.

## Lazy Evaluation (unstable)

```just
set unstable
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

NEVER put backticks or function calls in setting expressions:

```just
# BROKEN — backticks not allowed in settings
set working-directory := `pwd`

# CORRECT — use a variable
dir := `pwd`
```

NEVER expect dotenv settings in submodules to load env files — only the
root justfile's dotenv settings are honored.
