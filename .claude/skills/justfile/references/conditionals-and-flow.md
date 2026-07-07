---
name: conditionals-and-flow
description: >-
  If/else expressions, comparison operators, assert, error(), guards, and
  line sigils for controlling execution flow in justfiles.
metadata:
  tags: conditionals, if, else, assert, error, guards, sigils, flow-control
---

## `if`/`else` Expressions

Conditional expressions produce a value and can be used anywhere an expression
is valid — variable assignments, default parameters, and `{{…}}` interpolation.

```just
foo := if "2" == "2" { "Good!" } else { "1984" }
```

### Comparison Operators

| Operator | Meaning |
|----------|---------|
| `==` | String equality |
| `!=` | String inequality |
| `=~` | Regex match (use single-quoted strings for regex patterns) |
| `!~` | Regex non-match (1.39.0+) |

```just
foo := if env('CI', '') =~ 'true|1' { "--release" } else { "" }
```

### Chaining with `else if`

```just
mode := if env('MODE', '') == "prod" {
  "--release"
} else if env('MODE', '') == "test" {
  "--test"
} else {
  ""
}
```

### In recipe interpolations

```just
greet name:
  echo {{ if name == "world" { "Hello!" } else { "Hi, " + name + "!" } }}
```

### Short-circuit evaluation

Only the selected branch is evaluated. Backticks and function calls in the
other branch are NOT executed:

```just
# The backtick only runs when RELEASE is "true"
flag := if env('RELEASE', '') == "true" { `get-release-token` } else { "dev" }
```

## `error(message)`

Aborts execution with a custom message. Typically used inside conditionals:

```just
os := if os() == "linux" {
  "ok"
} else {
  error("Unsupported OS: " + os())
}
```

`error()` can appear anywhere an expression is valid.

## `assert(condition, message)`

Shorthand for aborting if a condition is false:

```just
foo := "hello"

bar:
  {{ assert(foo == "hello", "expected foo to be hello") }}
```

If the condition is false, execution aborts with the message. On success,
`assert()` returns an empty string.

The `message` argument is optional since 1.53.0: `assert(condition)` aborts
with a default message derived from the condition expression if false.

## Guards (`?` sigil)

Requires `set guards` (guard sigil and `guards` setting added in 1.47.0).
The `?` prefix on a recipe line causes the **current recipe** to stop if
the command exits with status `1`. Other recipes (including dependents)
continue running.

Without `set guards`, just does not raise an error: the `?` is passed to
the shell as part of the command, typically failing with
`command not found` (exit 127), which can be misdiagnosed as an unrelated
shell error.

A guard command that exits with a code other than `0` or `1` fails the
recipe: `` error: guard line in recipe `<name>` on line <line> returned
reserved exit code <code> ``.

```just
set guards

@foo: bar
  echo FOO

@bar:
  ?test -f required.txt
  echo BAR
```

If `required.txt` is missing, `bar` stops (skips `echo BAR`), but `foo`
still prints `FOO`.

Exit code `0` = continue. Exit code `1` = stop current recipe. All other
exit codes are reserved.

## Combining Sigils

Recipe lines accept combinations of `@`, `-`, and `?`, **except** `-` and
`?` which are mutually exclusive (infallible + guard is contradictory):

| Sigil | Effect |
|-------|--------|
| `@` | Toggle echo |
| `-` | Ignore non-zero exit |
| `?` | Guard (stop recipe on exit 1) |

```just
set guards

example:
  -@rm -f temp.txt       # quiet, ignore errors
  @?test -f config.yaml  # quiet, guard
```

## Anti-Patterns

NEVER use `>`, `<`, `>=`, or `<=` for comparisons — just only supports
`==`, `!=`, `=~`, and `!~`. For numeric-like comparisons, use regex
matching or shell logic inside a recipe body.

NEVER use `if`/`else` as a shell construct in a linewise recipe body —
it must be a just expression inside `{{…}}`, or a single-line shell
construct:

```just
# WRONG — this is not a just if/else, and multi-line shell breaks
wrong:
  if [ -f foo ]; then
    echo found
  fi

# CORRECT — just expression
right:
  echo {{ if path_exists("foo") == "true" { "found" } else { "missing" } }}

# CORRECT — single-line shell
right2:
  if [ -f foo ]; then echo found; fi
```

NEVER use boolean-returning functions bare in conditionals — they return
**strings**, not booleans. This applies to `path_exists()`,
`semver_matches()`, and `is_dependency()`:

```just
# WRONG — this is a type error, not a boolean check
foo := if path_exists("bar") { "yes" } else { "no" }
ok := if semver_matches(v, ">=1.0") { "yes" } else { "no" }

# CORRECT — always compare explicitly
foo := if path_exists("bar") == "true" { "yes" } else { "no" }
ok := if semver_matches(v, ">=1.0") == "true" { "yes" } else { "no" }
```
