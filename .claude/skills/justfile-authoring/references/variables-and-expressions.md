---
name: variables-and-expressions
description: >-
  Variable assignment, string types, operators, backtick evaluation, and
  interpolation in recipe bodies.
metadata:
  tags: variables, strings, expressions, interpolation, backticks, operators
---

## Variables

Assigned at the **top level** only (outside recipe bodies) using `:=`:

```just
version := "0.2.7"
tarball := "project-" + version + ".tar.gz"
```

Used in recipe bodies via `{{…}}` interpolation:

```just
publish:
  tar zcvf {{tarball}} src/
```

### Export / Unexport

```just
export RUST_BACKTRACE := "1"   # exported as env var to child processes
unexport SENSITIVE_VAR         # removes inherited env var from recipe scope
```

`set export` exports ALL just variables globally.

**Caveat:** exported variables are NOT available to backtick expressions in
the same scope — backticks evaluate before recipes run.

### CLI Overrides

```just
os := "linux"

build:
  ./build --os {{os}}
```

```console
$ just os=darwin build
$ just --set os darwin build
```

Submodule variables: `just foo::bar=VALUE` or `--set foo::bar VALUE`.

## String Types

| Syntax | Escapes | Notes |
|--------|---------|-------|
| `'raw'` | None | Literal characters, no processing |
| `"double"` | `\n \r \t \" \\ \u{XXXX}` | Standard escape sequences |
| `'''indented'''` | None | Leading newline stripped, common whitespace removed |
| `"""indented"""` | Yes | Same de-indentation + escape processing |
| `x'shell'` / `x"shell"` | Shell expansion | `$VAR`, `${VAR:-default}`, `~` — at **compile time** |
| `f'format'` / `f"format"` | Format string | `{{expr}}` interpolation inside strings |

### Single-quoted (raw)

```just
raw := '\t\n'   # literal backslash-t, backslash-n
```

### Double-quoted (with escapes)

```just
greeting := "Hello\tWorld\n"
emoji := "\u{1F916}"
continuation := "first line\
second line"              # backslash-newline joins lines
```

### Indented triple-quoted

```just
# Evaluates to "foo\nbar\n" — leading newline stripped, common indent removed
message := '''
  foo
  bar
'''
```

### Shell expansion strings (`x` prefix, 1.27.0)

Expanded at **compile time** — `.env` and `just` variables are NOT available:

```just
home := x'~'
config := x'${XDG_CONFIG_HOME:-~/.config}'
```

Supported: `$VAR`, `${VAR}`, `${VAR:-DEFAULT}`, `~`, `~USER`.

### Format strings (`f` prefix, 1.44.0)

```just
name := "world"
greeting := f'Hello, {{name}}!'
```

Use `{{{{` for a literal `{{` inside format strings.

## Operators

| Operator | Effect | Example |
|----------|--------|---------|
| `+` | String concatenation | `"foo" + "bar"` → `"foobar"` |
| `/` | Path join (always uses `/`) | `"src" / "main.rs"` → `"src/main.rs"` |
| `&&` | Logical AND on strings (unstable) | `'' && 'b'` → `''` |
| `||` | Logical OR on strings (unstable) | `'' \|\| 'b'` → `'b'` |

Parentheses for grouping and multi-line expressions:

```just
long_value := (
  "first" +
  "second" +
  "third"
)
```

Default parameter values containing `+`, `/`, `&&`, or `||` MUST be
parenthesized:

```just
test triple=(arch + "-unknown-unknown"):
  echo {{triple}}
```

Line continuation with `\` at end of line (1.15.0):

```just
a := 'foo' + \
     'bar'
```

## Backtick Command Evaluation

```just
# Single-line
localhost := `hostname -I | cut -d' ' -f1`

# Multi-line (triple backtick, de-indented like triple-quoted strings)
info := ```
  echo "os: $(uname)"
  echo "arch: $(uname -m)"
```
```

Backticks use the same shell as recipe lines (`set shell`).

NEVER start a backtick with `#!` — this syntax is reserved.

## Interpolation in Recipe Bodies

```just
publish:
  rm -f {{tarball}}
  mkdir {{tardir}}
```

Whitespace inside `{{…}}` is allowed: `{{ config }}` equals `{{config}}`.

To produce a literal `{{`, use `{{{{`:

```just
braces:
  echo 'I {{{{LOVE}} curly braces!'
```

## Anti-Patterns

NEVER try to assign just variables inside a recipe body:

```just
# BROKEN — recipe lines are shell commands, not just syntax
wrong:
  x := "hello"
  echo {{x}}
```

NEVER forget `{{}}` around variable references in recipes:

```just
name := "world"
# WRONG
greet:
  echo "Hello, name!"
# CORRECT
greet:
  echo "Hello, {{name}}!"
```

NEVER confuse `$VAR` (shell variable) with `{{var}}` (just variable) in
recipe bodies. `$VAR` is only meaningful if the variable is exported or set
in the shell environment.
