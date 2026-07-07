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
- A recipe stops at the first failing line; `just` exits with that
  command's exit code.

### The Default Recipe

`just` with no arguments runs:
1. The recipe marked `[default]` (1.43.0+), or
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

On just 1.52.0+, `set default-list` is the native alternative: it makes
bare `just` print the recipe list directly, without needing a `default`
recipe. Use the recipe idiom above when supporting older versions.

## Comments

Lines starting with `#` are comments. A `#` comment immediately before a
recipe (no blank line) becomes its **doc comment**, shown in `just --list`:

```just
# Build the project
build:
  cargo build
```

A `#` line inside a recipe **body** is a real recipe line: it is echoed
(like other commands) and passed to the shell, unless `set
ignore-comments` is active (see references/settings.md).

Only a **single** comment line becomes the doc shown in `just --list`:
the one immediately above the recipe header. When multiple `#` lines
precede a recipe with no blank line between them, only that **last** line
is shown — every earlier line is silently dropped from `--list` (it stays
in the file as an ordinary comment).

```just
# GOOD — single-line doc; the whole description survives in --list.
# Render one Markdown file to PDF (FILE with or without the .md extension).
pdf FILE:
  pandoc "{{FILE}}.md" -o "{{FILE}}.pdf"
```

```just
# BAD — the first line is the real summary, but --list only shows the
# second line, so the recipe appears documented by a dangling fragment.
# Render one Markdown file to PDF. FILE may be given with or
# without the .md extension.
pdf FILE:
  pandoc "{{FILE}}.md" -o "{{FILE}}.pdf"
```

For the BAD case, `just --list` prints:

```
pdf FILE # without the .md extension.
```

The leading "Render one Markdown file to PDF…" is gone and the remaining
fragment reads as a broken sentence. Fix it by collapsing the description
to one line (as in GOOD), or use `[doc("…")]` for explicit control over a
multi-line description:

```just
[doc('Render one Markdown file to PDF (FILE with or without .md).')]
pdf FILE:
  pandoc "{{FILE}}.md" -o "{{FILE}}.pdf"
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

House convention (not a `just` requirement): give every public recipe
(no `[private]` attribute, no underscore prefix) a one-line doc comment
immediately above the recipe header; it becomes the `--list` description.
Private helper recipes may omit it.

## Dependencies

### Prior dependencies (run before the recipe body)

```just
test: build
  ./run-tests
```

### Subsequent dependencies (run AFTER the recipe body)

`&&` in a dependency list introduces recipes that run **after** the body
completes. This is just syntax for dependency ordering, NOT shell `&&`:

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

**Do not confuse** parenthesized dependencies `(build "main")` (for passing
arguments, runs **before** body) with `&&` dependencies (for post-body
ordering). `deploy: (clean)` is a pre-body dep that passes no arguments —
use `deploy: && clean` to run `clean` **after** the body.

### Cross-module dependencies (1.42.0+)

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

# Default referencing an earlier parameter
copy src dst=src:
  cp {{src}} {{dst}}

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

A default expression may reference an earlier parameter: `copy src
dst=src` invoked as `just copy onlyone` gives `src=onlyone` and
`dst=onlyone`.

A variadic parameter's value is all matched arguments joined with
single spaces, so `{{FILES}}` cannot preserve the boundaries of
arguments that contain spaces: unquoted, such an argument splits into
separate words; quoted, all arguments merge into one word. For
space-safe forwarding use `set positional-arguments` (or the
`[positional-arguments]` attribute) with `"$@"` — see the forwarding
example in references/settings.md.

**Quoting caveat** — `{{param}}` is interpolated raw into the shell command.
A value with spaces causes word splitting:

```just
# WRONG — spaces break this
search QUERY:
  curl 'https://example.com/?q={{QUERY}}'
```

Always quote interpolations that may contain spaces, or use positional
arguments (`set positional-arguments` + `"$1"`).

### `[arg]` attribute — named options (1.46.0+)

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

Variadic `+`/`*` parameters may be options since 1.55.0: the resulting
`--long`/`-s` option is repeatable, with each occurrence appending one
value. On older `just` versions, making a variadic parameter into an
option is an error.

## Aliases

```just
alias b := build

build:
  echo 'Building!'
```

Aliases can target submodule recipes (1.40.0+): `alias baz := foo::bar`.

Aliases can also target a whole module (1.55.0+): `alias s := sub` makes
`just s <recipe>` work like `just sub <recipe>`.

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

Prefix recipe lines with combinations of (`-` and `?` are mutually exclusive):

| Sigil | Effect |
|-------|--------|
| `@` | Toggle echo (suppress if normally echoed, echo if recipe is quiet) |
| `-` | Continue on non-zero exit code |
| `?` | Stop current recipe if exit code is `1` (requires `set guards`) (1.47.0+) |

Without `set guards`, `?` is not an error: it is passed to the shell as
part of the command, typically failing with `command not found`.

```just
set guards

example:
  @echo 'quiet line'
  -rm -f maybe-missing.txt
  ?test -f required.txt
```

`@` on the recipe **name** inverts echo for all lines in that recipe.

## Anti-Patterns

NEVER put blank lines between comment lines and the recipe header — a blank
line breaks the doc comment association. Only the last `#` line with no
blank line before the recipe becomes the doc comment in `--list`. Use
`[doc("text")]` for explicit control.

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

NEVER use indented continuation in linewise recipes without `\` — just
reports `error: recipe line has extra leading whitespace`:

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

NEVER use `{{recipe_name}}` to call a recipe — `{{…}}` evaluates
expressions (variables, functions, conditionals), NOT recipes. To call
a recipe from another recipe's body, declare it as a dependency or
shell out: `just --justfile {{justfile()}} recipe-name`.

For complex multi-line logic, prefer
[shebang/script recipes](advanced-patterns.md).
