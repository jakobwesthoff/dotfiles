---
name: functions
description: >-
  Complete reference for all ~70 built-in functions — system info, environment,
  paths, strings, case conversion, hashing, datetime, and more.
metadata:
  tags: functions, built-in, path, string, env, hash, datetime
---

All functions return strings. Functions returning "true"/"false" return
literal strings, not booleans. Every `_directory` function has a `_dir`
alias (e.g., `home_dir()` = `home_directory()`).

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
node := which('node')     # empty string if not found (unstable)
```

`which()` requires `set unstable`. On Windows, both respect `PATHEXT`.

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
| `is_dependency()` | `"true"` if recipe is running as a dependency |

Use `source_directory()` inside modules for paths relative to that module.

## Path Manipulation

### Fallible (abort on invalid input)

| Function | Example |
|----------|---------|
| `absolute_path("./foo")` | `/project/foo` (lexical, no symlink resolution) |
| `canonicalize("./foo")` | Resolves symlinks; path must exist |
| `extension("/a/b.txt")` | `"txt"` |
| `file_name("/a/b.txt")` | `"b.txt"` |
| `file_stem("/a/b.txt")` | `"b"` |
| `parent_directory("/a/b")` | `"/a"` |
| `without_extension("/a/b.txt")` | `"/a/b"` |

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
| `replace_regex(s, regex, repl)` | Regex replace; `$1`, `$name` captures |
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

## User Directories

| Function | Returns |
|----------|---------|
| `home_directory()` | User home |
| `cache_directory()` | User cache dir |
| `config_directory()` | User config dir |
| `data_directory()` | User data dir |
| `executable_directory()` | User executable dir |

Platform-native paths (XDG on Linux, `~/Library/…` on macOS).

## Style

```just
@warning:
  echo '{{style("error")}}DANGER{{NORMAL}}'
```

Valid names: `"command"`, `"error"`, `"warning"`. Returns ANSI escapes
matching `just`'s own color scheme.
