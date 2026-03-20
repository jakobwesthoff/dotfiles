---
name: basics
description: >-
  Recipe syntax, dependencies, parameters, aliases, comments, and the default
  recipe — the foundational building blocks of every justfile.
metadata:
  tags: recipes, dependencies, parameters, aliases, comments, default
---

## Recipes

A recipe is a named target followed by `:`, with an indented body of shell commands:

```just
build:
  cc main.c foo.c -o main
```

- Names may contain letters, digits, `-`, and `_`. Kebab-case is conventional.
- Body lines use spaces **or** tabs, but NEVER mix within a single recipe.
- Each body line runs in a **separate shell invocation** — shell state (`cd`,
  variables) does NOT persist between lines.

### The Default Recipe

`just` with no arguments runs:
1. The recipe marked `[default]`, or
2. The first recipe in the file.

```just
default: lint build test

lint:
  echo 'Linting…'

build:
  echo 'Building…'

test:
  echo 'Testing…'
```

A common pattern — list available recipes:

```just
default:
  @just --list
```

## Comments

Lines starting with `#` are comments. A `#` comment immediately before a
recipe (no blank line) becomes its **doc comment**, shown in `just --list`:

```just
# Build the project
build:
  cargo build
```

Override or suppress with `[doc]`:

```just
[doc('Compile all targets')]
build:
  cargo build

[doc]
internal-helper:
  echo 'no doc shown'
```

## Dependencies

### Prior dependencies (run before the recipe body)

```just
test: build
  ./run-tests
```

### Subsequent dependencies (run after the recipe body)

```just
deploy: build && notify cleanup
  scp ./app server:/opt/
```

### Dependencies with arguments

```just
default: (build "main")

build target:
  @echo 'Building {{target}}…'
```

### Cross-module dependencies

```just
mod foo

bar: foo::build
  echo 'done'
```

### Deduplication

A recipe with the same arguments runs **at most once** per invocation,
regardless of how many dependents require it.

## Parameters

```just
# Required positional
build target:
  cargo build -p {{target}}

# With default (expressions with +, /, &&, || must be parenthesized)
test target tests='all':
  ./test --suite {{tests}} {{target}}

# Variadic: one or more
backup +FILES:
  scp {{FILES}} server:~/backups/

# Variadic: zero or more
commit MESSAGE *FLAGS:
  git commit {{FLAGS}} -m "{{MESSAGE}}"

# Exported as env var
foo $BAR:
  echo $BAR
```

**Quoting caveat** — `{{param}}` is interpolated raw into the shell command.
A value with spaces causes word splitting:

```just
# WRONG — spaces break this
search QUERY:
  curl 'https://example.com/?q={{QUERY}}'
```

Always quote interpolations that may contain spaces, or use positional
arguments (`set positional-arguments` + `"$1"`).

### `[arg]` attribute — named options (1.45.0+)

```just
[arg('output', long='output', short='o', help='Output directory')]
build output='./dist':
  echo "Building to {{output}}"
```

Invoked as: `just build --output ./build` or `just build -o ./build`.

Use `value="V"` to create a flag (no CLI value; parameter receives `V`):

```just
[arg('verbose', long='verbose', value='true')]
test verbose='false':
  echo "verbose={{verbose}}"
```

Variadic `+`/`*` parameters CANNOT be made into options.

## Aliases

```just
alias b := build

build:
  echo 'Building!'
```

Aliases can target submodule recipes: `alias baz := foo::bar`.

## Private Recipes

Hidden from `just --list` / `just --summary`:

```just
_helper:       # underscore prefix
  echo 'hidden'

[private]
also-hidden:   # attribute
  echo 'hidden'
```

## Line Sigils

Prefix recipe lines with any combination of:

| Sigil | Effect |
|-------|--------|
| `@` | Toggle echo (suppress if normally echoed, echo if recipe is quiet) |
| `-` | Continue on non-zero exit code |
| `?` | Stop current recipe if exit code is `1` (requires `set guards`) |

```just
set guards

example:
  @echo 'quiet line'
  -rm -f maybe-missing.txt
  ?test -f required.txt
```

`@` on the recipe **name** inverts echo for all lines in that recipe.

## Anti-Patterns

NEVER expect shell state to persist between linewise recipe lines:

```just
# BROKEN — cd has no effect on the next line
wrong:
  cd /tmp
  pwd

# CORRECT — chain on one line or use shebang
right:
  cd /tmp && pwd
```

NEVER use indented continuation in linewise recipes without `\`:

```just
# BROKEN — parse error from extra indentation
wrong:
  if true; then
    echo yes
  fi

# CORRECT
right:
  if true; then \
    echo yes; \
  fi
```

For complex multi-line logic, prefer
[shebang/script recipes](references/advanced-patterns.md).
