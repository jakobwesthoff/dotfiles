---
name: advanced-patterns
description: >-
  Shebang and script recipes, cross-platform patterns, fallback, parallel
  execution, constants, formatting, positional arguments, and common idioms.
metadata:
  tags: shebang, script, cross-platform, parallel, constants, idioms, formatting
---

## Shebang Recipes

Recipes whose first line starts with `#!` run as a single script in any
language:

```just
python:
  #!/usr/bin/env python3
  print('Hello from Python!')

ruby:
  #!/usr/bin/env ruby
  puts "Hello from Ruby!"
```

- Body is saved to a temp file, marked executable, and run.
- Shebang recipes are **quiet by default** (no line echoing).
- Shell state persists across all lines (unlike linewise recipes).
- Use `set -euxo pipefail` in bash shebangs for safety.

### Windows behavior

Windows has no native shebang support. `just` splits the shebang line into
command + args and invokes directly. Paths containing `/` are translated
via `cygpath`.

## Script Recipes (`[script]`)

A portable alternative to shebangs — avoids `cygpath`, `env`, and shebang
parsing differences:

```just
[script("python3")]
hello:
  print("Hello!")

[script("bash", "-euxo", "pipefail")]
deploy:
  echo "deploying…"
```

`[script]` (bare) uses `set script-interpreter` (default `sh -eu`):

```just
set script-interpreter := ['uv', 'run', '--script']

[script]
analyze:
  import pandas as pd
  print(pd.read_csv("data.csv").describe())
```

Use `[extension(".ext")]` to set the temp file extension (needed for some
interpreters):

```just
[extension(".ps1")]
[script("pwsh")]
windows-task:
  Write-Host "Hello from PowerShell"
```

## Cross-Platform Recipes

Provide platform-specific implementations with OS attributes and
`set allow-duplicate-recipes`:

```just
set allow-duplicate-recipes

[unix]
run:
  cc main.c && ./a.out

[windows]
run:
  cl main.c && main.exe
```

Conditional expressions work for simpler cases:

```just
ext := if os() == "windows" { ".exe" } else { "" }

run:
  ./build/app{{ext}}
```

## Parallel Execution

`[parallel]` runs all dependencies concurrently:

```just
[parallel]
all: build test lint

build:
  cargo build

test:
  cargo test

lint:
  cargo clippy
```

## Predefined Constants

### Hex character sets (1.27.0)

| Constant | Value |
|----------|-------|
| `HEX` / `HEXLOWER` | `"0123456789abcdef"` |
| `HEXUPPER` | `"0123456789ABCDEF"` |

### Path separators (1.41.0, platform-aware)

| Constant | Unix | Windows |
|----------|------|---------|
| `PATH_SEP` | `"/"` | `"\"` |
| `PATH_VAR_SEP` | `":"` | `";"` |

### ANSI terminal (1.37.0)

Text styles: `BOLD`, `ITALIC`, `UNDERLINE`, `INVERT`, `HIDE`, `STRIKETHROUGH`

Foreground: `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`

Background: `BG_BLACK`, `BG_RED`, `BG_GREEN`, `BG_YELLOW`, `BG_BLUE`,
`BG_MAGENTA`, `BG_CYAN`, `BG_WHITE`

Reset: `NORMAL` — always end styled output with this.
Clear: `CLEAR` — clears the terminal screen.

```just
@colorful:
  echo '{{BOLD + RED}}Error:{{NORMAL}} something went wrong'
```

## Formatting

```console
$ just --fmt --unstable           # reformat in place
$ just --fmt --check --unstable   # CI check (exit 1 if unformatted)
$ just --dump                     # print formatted to stdout
```

`--fmt` is currently unstable.

## Multi-Line Constructs

Each linewise recipe line is a separate shell invocation. Multi-line shell
constructs require workarounds:

```just
# Option A: single line
loop:
  for f in *.txt; do echo "$f"; done

# Option B: escaped newlines
loop2:
  for f in *.txt; do \
    echo "$f"; \
  done

# Option C: shebang (best for complex logic)
loop3:
  #!/usr/bin/env bash
  for f in *.txt; do
    echo "$f"
  done
```

## Common Idioms

### Default recipe listing

```just
default:
  @just --list
```

### CLI-configurable variables

```just
mode := "debug"
target := "x86_64"

build:
  ./build --mode {{mode}} --target {{target}}
```

```console
$ just mode=release target=aarch64 build
```

### Dotenv for environment config

```just
set dotenv-load

serve:
  ./server --port $PORT --db $DATABASE_URL
```

### Wrapping external tools

```just
[no-exit-message]
git *args:
  @git {{args}}
```

### Python virtual environments

```just
venv:
  [ -d .venv ] || python3 -m venv .venv

run: venv
  .venv/bin/python3 main.py
```

### Just as script interpreter

```
#!/usr/bin/env just --justfile

build:
  echo "building…"
```

On Linux, `env` may need `-S`: `#!/usr/bin/env -S just --justfile`.

Add `--working-directory .` to keep CWD at invocation point rather than
the script's location.

## Anti-Patterns

NEVER use Make syntax in justfiles — `just` is NOT `make`:
- No automatic variables (`$@`, `$<`, `$^`)
- No pattern rules or `%` wildcards
- No tab-vs-space significance (both work, but must be consistent per recipe)
- `:=` is for variable assignment, not recipe definitions

NEVER write complex shell logic in linewise recipes — use shebang or
`[script]` recipes instead. Each line being a separate shell invocation
makes multi-line logic fragile and error-prone.

NEVER expect `source`, `cd`, or shell variable assignments to persist
between linewise recipe lines.
