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

If the condition is false, execution aborts with the message.

## Guards (`?` sigil)

Requires `set guards`. The `?` prefix on a recipe line causes the
**current recipe** to stop if the command exits with status `1`. Other recipes
(including dependents) continue running.

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

Recipe lines accept any combination of `@`, `-`, and `?`:

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
