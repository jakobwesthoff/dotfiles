---
name: attributes
description: >-
  All recipe and module attributes — platform targeting, groups, script
  execution, confirmation, documentation, and argument options.
metadata:
  tags: attributes, platform, group, script, confirm, private, doc, arg
---

Attributes are placed on lines immediately before a recipe, `mod`, or alias.
Doc comments (`#`) must come **before** attributes — the sequence must be
`# comment` → `[attr]` → `recipe:`. Placing a `#` comment after an attribute
causes an `extraneous attribute` error.

## Syntax Forms

```just
[private]                       # no argument
[group("build")]                # with argument
[group: "build"]                # colon shorthand (single-argument only)
[no-cd, private]                # comma-separated on one line
[arg("n", long, short="n")]     # multiple keyword arguments
```

Multiple attributes can be stacked on separate lines. `[arg]`, `[env]`,
`[group]`, and `[metadata]` are **repeatable**.

Attribute arguments may be expressions, not just literals, for `[confirm]`
(1.49.0+), `[env]` and `[working-directory]` (1.51.0+) — e.g.
`[working-directory(justfile_directory() / 'build')]`. Shell-expanded
`x'...'` strings are also allowed as attribute arguments (1.45.0+).

## Complete Reference

### Execution Control

| Attribute | Description |
|-----------|-------------|
| `[script("cmd", "args…")]` | Run body as script file via `cmd` (1.32.0, stabilized 1.44.0) |
| `[script]` | Run via `script-interpreter` setting (default `sh -eu`) (1.33.0+) |
| `[extension(".ext")]` | Set temp file extension for script/shebang recipes |
| `[no-cd]` | Run in invocation directory, not justfile directory |
| `[working-directory("path")]` | Override working directory |
| `[confirm]` / `[confirm("prompt")]` | Require interactive confirmation (bypass with `--yes`) |
| `[no-exit-message]` | Suppress failure error message |
| `[exit-message]` (1.39.0+) | Print error message if recipe fails, regardless of `set no-exit-message` |
| `[no-quiet]` | Echo lines even when `set quiet` is active |
| `[positional-arguments]` | Enable `$1`, `$2`, `$@` for this recipe |
| `[parallel]` (1.42.0+) | Run dependencies concurrently |
| `[env("VAR", "VALUE")]` (1.47.0+) | Set env var for this recipe (repeatable) |
| `[default]` (1.43.0+) | Use as module's default recipe |
| `[shell]` (1.52.0+) | Execute recipe as a shell recipe, overriding `set default-script`. Bare flag taking no arguments; it does not select which shell |
| `[continue]` / `[continue("SIGHUP", ...)]` (1.54.0+) | Signal tolerance, not continue-on-error: proceed normally if a command is interrupted by one of the given signals yet exits successfully; defaults to `SIGINT`. A command exiting non-zero still fails the recipe |
| `[cache]` (1.54.0+, unstable, script recipes only) | Cache recipe output; parameters `inputs`, `outputs`, `extra`; cache stored in `.justcache` next to the justfile |

### Visibility & Documentation

| Attribute | Description |
|-----------|-------------|
| `[private]` | Hide from `--list` and `--summary` |
| `[doc("text")]` | Override doc comment shown in `--list` |
| `[doc]` | Suppress doc comment entirely |
| `[group("name")]` | Assign to a named group in `--list` (repeatable) |
| `[metadata("v1", "v2")]` (1.42.0+) | Arbitrary metadata (readable via `--dump --dump-format json`) |

### Platform Targeting

| Attribute | Platform |
|-----------|----------|
| `[linux]` | Linux only |
| `[macos]` | macOS only |
| `[unix]` | All Unix (includes macOS) |
| `[windows]` | Windows only |
| `[android]` (1.50.0+) | Android only |
| `[freebsd]` | FreeBSD |
| `[netbsd]` | NetBSD |
| `[openbsd]` | OpenBSD |
| `[dragonfly]` | DragonFly BSD |

A recipe without platform attributes runs on **all** platforms. Once any
platform attribute is present, the recipe is only enabled when at least one
matches.

Cross-platform pattern (requires `set allow-duplicate-recipes`):

```just
set allow-duplicate-recipes

[unix]
build:
  cc main.c -o main

[windows]
build:
  cl main.c
```

### `[arg]` — Parameter Options (1.46.0+)

Controls how recipe parameters are passed from the CLI.

```just
[arg("output", long="output", short="o", help="Output directory")]
[arg("verbose", long="verbose", value="true")]
build output="./dist" verbose="false":
  echo "Building to {{output}}, verbose={{verbose}}"
```

| Keyword | Effect |
|---------|--------|
| `long="name"` | Named `--name` option |
| `long` | Named option using parameter name |
| `short="c"` | Short `-c` option |
| `pattern="regex"` (1.45.0+) | Constrain value (auto-anchored with `^…$`) |
| `value="V"` | Flag mode — no CLI value, parameter receives `V` when present |
| `help="text"` | Description shown in `--usage` output |

A parameter can have both `long` and `short`. `value` makes it a flag
(no value taken from CLI).

Variadic `+`/`*` parameters may be options since 1.55.0: the resulting
`--long`/`-s` option is repeatable, with each occurrence appending one
value. On older `just` versions, making a variadic parameter into an
option is an error.

Other `[arg]` additions in 1.55.0:
- `[arg(multiple)]` allows a non-variadic parameter to accept multiple values.
- Bare `short` defaults to the first character of the parameter name.
- Combined short options are accepted on the CLI.
- `help`, `pattern`, and `value` may be const expressions, and `pattern`
  may be a list.

`--list` does not reveal `[arg]`-defined option names — use
`just --usage <recipe>` (1.46.0+) to see the generated CLI interface.

## Applicability

| Attribute | Recipe | Module | Alias |
|-----------|:------:|:------:|:-----:|
| `[doc]` | yes | yes | no |
| `[group]` | yes | yes | no |
| `[private]` | yes | yes (1.47.0+) | yes |
| All others | yes | no | no |

`[private]` above a variable assignment also hides it from
`--evaluate`/`--variables`, same as an underscore-prefixed variable name.

## Anti-Patterns

NEVER use platform attributes without `set allow-duplicate-recipes` when
providing multiple implementations of the same recipe name — this causes
a duplicate recipe error.

NEVER put `[script]` on a recipe that already has a shebang line — choose
one approach. `[script]` is the more portable option (avoids shebang
parsing issues on Windows).
