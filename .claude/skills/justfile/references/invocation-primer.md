---
name: invocation-primer
description: >-
  How justfiles are invoked — recipe execution, argument passing, variable
  overrides, and CLI flags that affect authoring decisions.
metadata:
  tags: invocation, cli, arguments, flags, execution, usage
---

Understanding how users invoke `just` is essential for writing good justfiles.
This primer covers the consumer-side behavior that affects authoring decisions.

## Basic Invocation

```console
$ just                        # run the default recipe
$ just build                  # run a specific recipe
$ just build arg1 arg2        # pass positional arguments
$ just build test deploy      # run multiple recipes in sequence
```

**Caveat:** a recipe with parameters consumes subsequent tokens as arguments,
not as recipe names:

```console
$ just build serve    # if build takes a parameter, "serve" becomes that parameter!
```

## Submodule Invocation

```console
$ just backend build          # subcommand style (space)
$ just backend::build         # path style (double colon)
$ just outer::inner::task     # nested modules
```

### Path shortcut

If the first argument contains `/`, it's split at the last `/`:

```console
$ just foo/build    # equivalent to (cd foo && just build)
$ just foo/         # run default recipe in foo/
```

## Argument Mapping

Arguments are matched left-to-right to recipe parameters:

```just
test target tests='all':
  ./test --suite {{tests}} {{target}}
```

```console
$ just test server           # target=server, tests=all
$ just test server unit      # target=server, tests=unit
```

Variadic `+param` consumes all remaining args (1+). `*param` consumes
zero or more.

## Variable Overrides

```console
$ just os=darwin build             # NAME=VALUE before recipe
$ just --set os darwin build       # --set flag
```

## Key Flags for Authoring Decisions

### `--list` / `-l`

Shows available recipes. This is why `[group]`, `[doc]`, `[private]`,
and doc comments matter:

```console
$ just --list
$ just --list --unsorted          # preserve source order
$ just --list foo                 # list submodule recipes
$ just --list --list-submodules   # recursive listing (requires --list)
$ just --groups                   # list all groups
```

Customize output: `--list-heading`, `--list-prefix`.

### `--dry-run` / `-n`

Print commands without executing. Useful for verifying complex recipes.

**Caveats:** backtick expressions in variables are shown unevaluated (the
literal backtick expression, not the computed value). `[confirm]` recipes
still prompt for confirmation — pass `--yes` alongside `--dry-run`.

### `--choose`

Interactive recipe picker (defaults to `fzf`). Excludes recipes requiring
arguments, private recipes, and aliases. Design default-able recipes
to work well with this.

### `--dump` / `--fmt`

```console
$ just --dump                          # print formatted justfile
$ just --dump --dump-format json       # JSON representation
$ just --fmt --unstable                # reformat in place
$ just --fmt --check --unstable        # CI format check
```

### `--justfile` / `-f` and `--working-directory` / `-d`

Users can point `just` at a specific justfile. Inside recipes, use
`justfile()` and `justfile_directory()` for portable self-references.

### Quiet/Verbose

```console
$ just --quiet recipe     # suppress ALL output (different from set quiet)
$ just --verbose recipe   # extra output
```

`just --quiet` suppresses recipe stdout. `set quiet` only suppresses
command echoing. Design accordingly.

### Unstable Features

```console
$ just --unstable recipe
$ JUST_UNSTABLE=1 just recipe
```

Or in the justfile: `set unstable`. Features like `lazy`, `which()`,
`&&`/`||` operators require this.

## `[arg]` and Invocation UX

The `[arg]` attribute transforms positional parameters into named CLI options:

```just
[arg("output", long="output", short="o")]
[arg("verbose", long="verbose", value="true")]
build output="./dist" verbose="false":
  echo "{{output}} {{verbose}}"
```

```console
$ just build --output ./build --verbose
$ just build -o ./build
```

This makes recipes feel like proper CLI tools. Use `--usage` to see
generated usage info:

```console
$ just --usage build
```

## Global Justfile

```console
$ just -g recipe     # searches ~/.config/just/justfile etc.
```

## Environment Variable Equivalents

| Flag | Env Var |
|------|---------|
| `--unstable` | `JUST_UNSTABLE` |
| `--dry-run` | `JUST_DRY_RUN` |
| `--quiet` | `JUST_QUIET` |
| `--verbose` | `JUST_VERBOSE` |
| `--justfile` | `JUST_JUSTFILE` |
| `--working-directory` | `JUST_WORKING_DIRECTORY` |
| `--tempdir` | `JUST_TEMPDIR` |
| `--chooser` | `JUST_CHOOSER` |
| `--list-submodules` | `JUST_LIST_SUBMODULES` |
