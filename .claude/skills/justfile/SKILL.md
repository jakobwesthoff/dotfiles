---
name: justfile
description: >-
  Write correct, idiomatic Justfiles with just. Use when creating a Justfile,
  writing just recipes, adding project tasks, or mentioning "justfile", "just",
  or ".just".
---

## When to use

Use this skill when asked to create, modify, or review a Justfile — the task
file format for the [`just`](https://github.com/casey/just) command runner.

These reference files are self-contained — prefer them over external sources.

## Key Concepts

`just` is a command runner, NOT a build system. Justfiles define named recipes
(tasks) with shell commands, variables, and expressions. Key differences from
`make`: no file targets, no automatic variables, no implicit rules, spaces and
tabs both work (but must be consistent per recipe).

## Decision Tree

| Task | Start here |
|------|------------|
| Writing a basic justfile | [references/basics.md](references/basics.md) |
| Variables, strings, interpolation | [references/variables-and-expressions.md](references/variables-and-expressions.md) |
| Using built-in functions | [references/functions.md](references/functions.md) |
| Conditional logic, error handling | [references/conditionals-and-flow.md](references/conditionals-and-flow.md) |
| Configuring shell, dotenv, quiet mode | [references/settings.md](references/settings.md) |
| Recipe attributes (platform, groups, scripts) | [references/attributes.md](references/attributes.md) |
| Splitting into multiple files | [references/modules-and-imports.md](references/modules-and-imports.md) |
| Shebang recipes, cross-platform, idioms | [references/advanced-patterns.md](references/advanced-patterns.md) |
| Understanding how users invoke recipes | [references/invocation-primer.md](references/invocation-primer.md) |

## Validating justfiles

Run each `just` command as its own standalone Bash call with no shell
additions. NEVER append `2>&1`, `|| echo ...`, `&&`, `for` loops, or
any other compound shell constructs.

```bash
just --justfile /path/to/justfile --dump
just --justfile /path/to/justfile --list
just --justfile /path/to/justfile --dry-run recipe-name
just --justfile /path/to/justfile --fmt --check --unstable
```

Silent `--dump` output to stdout = valid parse. Errors print to stderr.
Note: `--dump` only checks syntax — it does not evaluate variables, so
`error()` and `assert()` at variable level are NOT triggered.

## Critical Rules

- Each linewise recipe line runs in a **separate shell**. Shell state (`cd`,
  variables) does NOT persist between lines. Use shebang or `[script]` recipes
  for multi-line logic.
- Use `{{variable}}` to interpolate just variables in recipe bodies. Bare
  `variable` or `$variable` references shell variables, not just variables.
- `{{{{` produces a literal `{{` in recipe bodies.
- `{{…}}` evaluates **expressions** only — NEVER use it to invoke recipes.
- NEVER mix tabs and spaces within a single recipe's indentation.
- Functions like `path_exists()`, `semver_matches()`, and `is_dependency()`
  return **strings** `"true"`/`"false"`, not booleans — always compare with
  `== "true"`.
- `import` merges into the current scope (flat inclusion). `mod` creates an
  **isolated** namespace — parent variables are NOT visible inside modules
  and vice versa.
- NEVER add `set unstable` preemptively. Write the justfile without it and
  validate with `--dump`. If `just` reports a feature is unstable, inform the
  user and get explicit approval before adding `set unstable`. This makes the
  installed `just` version the source of truth — unstable markers in this
  skill may be outdated.

## Reference Files

- [references/basics.md](references/basics.md) — Recipes, dependencies, parameters, aliases, comments, line sigils
- [references/variables-and-expressions.md](references/variables-and-expressions.md) — Assignment, string types, operators, backticks, interpolation
- [references/functions.md](references/functions.md) — All ~70 built-in functions by category
- [references/conditionals-and-flow.md](references/conditionals-and-flow.md) — If/else, assert, error(), guards
- [references/settings.md](references/settings.md) — All `set` directives, shell config, dotenv, export
- [references/attributes.md](references/attributes.md) — Platform targeting, groups, script execution, arg options
- [references/modules-and-imports.md](references/modules-and-imports.md) — `mod`, `import`, submodule isolation, file resolution
- [references/advanced-patterns.md](references/advanced-patterns.md) — Shebang/script recipes, cross-platform, constants, idioms
- [references/invocation-primer.md](references/invocation-primer.md) — CLI invocation, argument passing, flags affecting authoring
