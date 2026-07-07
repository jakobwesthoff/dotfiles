---
name: functions
description: >-
  Complete reference for all ~70 built-in functions — system info, environment,
  paths, strings, case conversion, hashing, datetime, and more.
metadata:
  tags: functions, built-in, path, string, env, hash, datetime
---

All functions return strings. All function **arguments** are strings too —
numeric-looking parameters like `choose(n, ...)` must be quoted:
`choose('64', HEX)`, not `choose(64, HEX)`. Functions returning
"true"/"false" return literal strings, not booleans. Every `_directory`
function has a `_dir` alias (e.g., `home_dir()` = `home_directory()`).

## System Information

| Function | Returns |
|----------|---------|
| `arch()` | CPU architecture: `"x86_64"`, `"aarch64"`, etc. |
| `os()` | OS name: `"linux"`, `"macos"`, `"windows"`, etc. |
| `os_family()` | `"unix"` or `"windows"` |
| `num_cpus()` | Logical CPU count as string |

## Environment Variables

```just
home := env('HOME')                    # abort if missing
port := env('PORT', '8080')            # fallback if missing
```

`env_var()` and `env_var_or_default()` are **deprecated** — use `env()`.

## Executables

```just
bash := require('bash')   # abort if not in PATH
node := which('node')     # empty string if not found (requires set lists)
```

`which()` requires `set lists` (which is unstable, so `set unstable` is also
needed). On Windows, both respect `PATHEXT`.

## Invocation & File Info

| Function | Returns |
|----------|---------|
| `justfile()` | Path to **root** justfile (even from submodules) |
| `justfile_directory()` | Directory of root justfile |
| `source_file()` | Path to **current** source file (differs in imports/modules) |
| `source_directory()` | Directory of current source file |
| `module_file()` | Path to current module's source file |
| `module_directory()` | Directory of current module's source file |
| `invocation_directory()` | CWD when `just` was invoked (cygpath on Windows) |
| `invocation_directory_native()` | CWD, native path on all platforms |
| `just_executable()` | Path to the `just` binary |
| `just_pid()` | Process ID of running `just` |
| `just_version()` | Version of the running `just` (1.55.0), e.g. `"1.55.0"` |
| `is_dependency()` | `"true"` if recipe is running as a dependency |
| `recipe_name()` | Name of the current recipe (1.53.0) |
| `module_path()` | `::`-separated path to the current module (1.50.0) |

Use `source_directory()` inside modules for paths relative to that module.

## Path Manipulation

### Fallible (abort on invalid input)

| Function | Example |
|----------|---------|
| `absolute_path("./foo")` | `/project/foo` (lexical, no symlink resolution) |
| `canonicalize("./foo")` | Resolves symlinks; path must exist when evaluated [^1] |
| `extension("/a/b.txt")` | `"txt"` |
| `file_name("/a/b.txt")` | `"b.txt"` |
| `file_stem("/a/b.txt")` | `"b"` |
| `parent_directory("/a/b")` | `"/a"` |
| `without_extension("/a/b.txt")` | `"/a/b"` |

[^1]: For variable assignments, evaluation happens at justfile load;
for recipe interpolations, it happens when the containing line
executes.

### Infallible

| Function | Example |
|----------|---------|
| `clean("foo//bar/./baz")` | `"foo/bar/baz"` (lexical only) |
| `join("a", "b", "c")` | `"a/b/c"` (uses OS separator — `\` on Windows) |

Prefer the `/` operator over `join()` for consistent cross-platform paths.

## String Manipulation

| Function | Description |
|----------|-------------|
| `replace(s, from, to)` | Replace all literal occurrences |
| `replace_regex(s, regex, repl)` | Regex replace; `${1}`, `$name` captures. Use braces (`${1}`) when followed by alphanumerics/`_` — bare `$1_` is parsed as group name `1_` |
| `trim(s)` | Strip leading + trailing whitespace |
| `trim_start(s)` / `trim_end(s)` | Strip one side |
| `trim_start_match(s, pat)` | Remove prefix once |
| `trim_start_matches(s, pat)` | Remove prefix repeatedly |
| `trim_end_match(s, pat)` | Remove suffix once |
| `trim_end_matches(s, pat)` | Remove suffix repeatedly |
| `quote(s)` | Shell-safe single-quoting |
| `append(suffix, s)` | Append to each whitespace-separated word |
| `prepend(prefix, s)` | Prepend to each whitespace-separated word |
| `encode_uri_component(s)` | Percent-encode for URLs |

**Regex escaping:** in double-quoted strings, backslashes need doubling
(`"\\d+"` for `\d+`). Use single-quoted raw strings for regex patterns:
`replace_regex(s, '\d+', 'NUM')`.

## Case Conversion

| Function | Output style |
|----------|-------------|
| `capitalize(s)` | First char upper, rest lower |
| `lowercase(s)` / `uppercase(s)` | All lower / all upper |
| `kebabcase(s)` | `kebab-case` |
| `snakecase(s)` | `snake_case` |
| `shoutysnakecase(s)` | `SHOUTY_SNAKE_CASE` |
| `shoutykebabcase(s)` | `SHOUTY-KEBAB-CASE` |
| `lowercamelcase(s)` | `lowerCamelCase` |
| `uppercamelcase(s)` | `UpperCamelCase` |
| `titlecase(s)` | `Title Case` |

## Filesystem

```just
exists := path_exists("/tmp/lock")   # "true" or "false" (string!)
content := read("config.toml")       # file contents as string
```

`path_exists()` returns strings — compare with `== "true"`, not bare.

## Hashing & UUID

| Function | Description |
|----------|-------------|
| `sha256(s)` / `sha256_file(path)` | SHA-256 hex digest |
| `blake3(s)` / `blake3_file(path)` | BLAKE3 hex digest |
| `uuid()` | Random UUID v4 |
| `choose(n, alphabet)` | `n` random chars from `alphabet` (no dupes in alphabet) |

```just
token := choose('64', HEX)   # 64-char random hex string
```

## Datetime

```just
today := datetime('%Y-%m-%d')           # local time
ts := datetime_utc('%Y%m%d%H%M%S')     # UTC
```

Format uses `strftime`-style specifiers (chrono crate).

## Semantic Versioning

```just
ok := semver_matches('1.2.3', '>=1.0.0')   # "true"
```

## Shell Execution

```just
kernel := shell('uname -r')
lines := shell('wc -l "$1"', 'main.c')   # $1 = first extra arg
```

Runs through the configured shell. Aborts on non-zero exit.

## Error & Flow Control

```just
os := if os() == "linux" { "ok" } else { error("unsupported: " + os()) }
```

`error(message)` aborts execution unconditionally.

`assert(condition, message)` aborts with `message` if `condition` is not
`"true"`; returns the empty string on success. `message` is optional since
1.53.0.

## User Directories

| Function | Returns |
|----------|---------|
| `home_directory()` | User home |
| `cache_directory()` | User cache dir |
| `config_directory()` | User config dir |
| `config_local_directory()` | Local user config dir |
| `data_directory()` | User data dir |
| `data_local_directory()` | Local user data dir |
| `executable_directory()` | User executable dir |
| `runtime_directory()` | User runtime dir (1.49.0); only defined on Linux |

Platform-native paths (XDG on Linux, `~/Library/…` on macOS).

`runtime_directory()` aborts with an error on platforms that define no
runtime directory, including macOS.

## Style

```just
@warning:
  echo '{{style("error")}}DANGER{{NORMAL}}'
```

Baseline names (1.37.0): `"command"`, `"error"`, `"warning"`. Returns ANSI
escapes matching `just`'s own color scheme.

Since 1.55.0, `style()` also accepts: named colors (`black`, `blue`, `cyan`,
`green`, `magenta`, `red`, `white`, `yellow`); 256 indexed colors (integers
`0`-`255`); 24-bit hex colors (`#RRGGBB`/`#RGB`); and display properties
(`blink`, `bold`, `dim`, `hidden`, `italic`, `reverse`, `strikethrough`,
`underline`). Color styles color the foreground by default; use the `fg:`
prefix for an explicit foreground variant or `bg:` for background (e.g.
`bg:blue`, `fg:133`). Stream gates `stdout`/`stderr` emit the style only
when `just` would color that stream (per `--color`/`JUST_COLOR`/TTY
detection). Combine multiple styles by concatenating calls with `+`:
`style("bold") + style("red")`.

The two-argument form `style(styles, text)` (1.55.0) styles `text` and
resets automatically, removing the need for a trailing `{{NORMAL}}`:

```just
@warning:
  echo '{{style("error", "DANGER")}}'
```

## User-defined functions

`name(params) := expression` (1.49.0+, currently unstable, requires `set
unstable`) defines a function callable like a built-in. Functions may
reference assignments in the same module:

```just
set unstable

greeting := "Hello"
hello(name) := f"{{ greeting }}, {{ name }}!"
```
