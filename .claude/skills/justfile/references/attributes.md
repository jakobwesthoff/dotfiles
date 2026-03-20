---
name: attributes
description: >-
  All recipe and module attributes — platform targeting, groups, script
  execution, confirmation, documentation, and argument options.
metadata:
  tags: attributes, platform, group, script, confirm, private, doc, arg
---

Attributes are placed on lines immediately before a recipe, `mod`, or alias.

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

## Complete Reference

### Execution Control

| Attribute | Description |
|-----------|-------------|
| `[script("cmd", "args…")]` | Run body as script file via `cmd` |
| `[script]` | Run via `script-interpreter` setting (default `sh -eu`) |
| `[extension(".ext")]` | Set temp file extension for script/shebang recipes |
| `[no-cd]` | Run in invocation directory, not justfile directory |
| `[working-directory("path")]` | Override working directory |
| `[confirm]` / `[confirm("prompt")]` | Require interactive confirmation (bypass with `--yes`) |
| `[no-exit-message]` | Suppress failure error message |
| `[no-quiet]` | Echo lines even when `set quiet` is active |
| `[positional-arguments]` | Enable `$1`, `$2`, `$@` for this recipe |
| `[parallel]` | Run dependencies concurrently |
| `[env("VAR", "VALUE")]` | Set env var for this recipe (repeatable) |
| `[default]` | Use as module's default recipe |

### Visibility & Documentation

| Attribute | Description |
|-----------|-------------|
| `[private]` | Hide from `--list` and `--summary` |
| `[doc("text")]` | Override doc comment shown in `--list` |
| `[doc]` | Suppress doc comment entirely |
| `[group("name")]` | Assign to a named group in `--list` (repeatable) |
| `[metadata("v1", "v2")]` | Arbitrary metadata (readable via `--dump --dump-format json`) |

### Platform Targeting

| Attribute | Platform |
|-----------|----------|
| `[linux]` | Linux only |
| `[macos]` | macOS only |
| `[unix]` | All Unix (includes macOS) |
| `[windows]` | Windows only |
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

### `[arg]` — Parameter Options (1.45.0+)

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
| `pattern="regex"` | Constrain value (auto-anchored with `^…$`) |
| `value="V"` | Flag mode — no CLI value, parameter receives `V` when present |
| `help="text"` | Description shown in `--usage` output |

A parameter can have both `long` and `short`. `value` makes it a flag
(no value taken from CLI).

Variadic `+`/`*` parameters CANNOT be made into options.

## Applicability

| Attribute | Recipe | Module | Alias |
|-----------|:------:|:------:|:-----:|
| `[doc]` | yes | yes | no |
| `[group]` | yes | yes | no |
| `[private]` | yes | no | yes |
| All others | yes | no | no |

## Anti-Patterns

NEVER use platform attributes without `set allow-duplicate-recipes` when
providing multiple implementations of the same recipe name — this causes
a duplicate recipe error.

NEVER put `[script]` on a recipe that already has a shebang line — choose
one approach. `[script]` is the more portable option (avoids shebang
parsing issues on Windows).
