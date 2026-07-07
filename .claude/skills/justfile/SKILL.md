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

## Validating justfiles

Run each `just` command as its own standalone Bash call with no shell
additions. NEVER append `2>&1`, `|| echo ...`, `&&`, `for` loops, or
any other compound shell constructs.

```bash
just --justfile /path/to/justfile --dump
just --justfile /path/to/justfile --list
just --justfile /path/to/justfile --dry-run recipe-name
just --justfile /path/to/justfile --fmt --check
just --justfile /path/to/justfile --evaluate
```

`--dump` prints the formatted justfile to stdout and exits 0 on a valid
parse; parse errors go to stderr with a non-zero exit. `--dump` only
checks syntax — it does not evaluate variables, so `error()` and
`assert()` at variable level are NOT triggered. `--evaluate` closes
that gap by evaluating all top-level variables, so variable-level
`error()`/`assert()` do trigger — but it also executes backticks and
`shell()` calls, so inspect the justfile for side-effecting backticks
before running it.

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
- Give every public recipe a one-line doc comment (house convention; it
  becomes the `--list` description).

## Reference Files

| File | Start here for... |
|------|--------------------|
| [references/basics.md](references/basics.md) | Writing a basic justfile — recipes, dependencies, parameters, aliases, comments, line sigils |
| [references/variables-and-expressions.md](references/variables-and-expressions.md) | Variables, strings, interpolation — assignment, string types, operators, backticks |
| [references/functions.md](references/functions.md) | Using built-in functions — all ~70 built-in functions by category |
| [references/conditionals-and-flow.md](references/conditionals-and-flow.md) | Conditional logic, error handling — if/else, assert, error(), guards |
| [references/settings.md](references/settings.md) | Configuring shell, dotenv, quiet mode — all `set` directives, shell config, dotenv, export |
| [references/attributes.md](references/attributes.md) | Recipe attributes (platform, groups, scripts) — platform targeting, groups, script execution, arg options |
| [references/modules-and-imports.md](references/modules-and-imports.md) | Splitting into multiple files — `mod`, `import`, submodule isolation, file resolution |
| [references/advanced-patterns.md](references/advanced-patterns.md) | Shebang recipes, cross-platform, idioms — shebang/script recipes, cross-platform, constants |
| [references/invocation-primer.md](references/invocation-primer.md) | Understanding how users invoke recipes — CLI invocation, argument passing, flags affecting authoring |
