# Stale shell config referencing tools that are not installed (and not in the Brewfile)

**Area**: shell-env
**Files**: /Users/jakob/dotfiles/.zshrc.d/050_aliases.sh, .zshrc.d/050_itermocil.sh, .zshrc.d/050_functions.sh, .zshrc.d/050_kubectl.sh, .fasdrc

## Current state / Problem

All checks run 2026-07-04 with `command -v <tool>` on this machine, and by
searching the Brewfile; every item below is *neither on PATH nor in the
Brewfile* unless noted.

1. **`.zshrc.d/050_aliases.sh:7`** — `alias mtail=multitail`: `multitail` not
   installed.
2. **`.zshrc.d/050_aliases.sh:10`** — `alias sant="ant -logger ..."`: `ant`
   not installed.
3. **`.zshrc.d/050_aliases.sh:15`** —
   `alias server='open http://localhost:8000 && python -m SimpleHTTPServer'`:
   doubly broken. `python` is not on PATH (only `python3` from
   `python@3.14`), and `SimpleHTTPServer` is the Python 2 module name; the
   Python 3 equivalent is `http.server`.
4. **`.zshrc.d/050_aliases.sh:36-37`** — `alias vscode="code"`,
   `alias vsc="code"`: `code` not on PATH, VS Code not installed
   (`/Applications/Visual Studio Code.app` absent, no cask in Brewfile).
5. **`.zshrc.d/050_aliases.sh:18-19`** — `ptrace`/`pprofile` set
   `xdebug.*` ini values, but the installed PHP 8.5.7 has no xdebug extension
   (`php -m | grep -i xdebug` → no match).
6. **`.zshrc.d/050_itermocil.sh`** — completion for `itermocil`: the tool is
   not installed and its data dir `~/.teamocil` does not exist. itermocil was
   an iTerm2-specific tool; the terminal in use is ghostty.
7. **`.fasdrc`** — `fasd` is not installed and is referenced nowhere else in
   the repo (`grep -rn fasd` over `.zshrc*`, `.zprofile.d`, `bin` → no other
   hits). Directory jumping is handled by zoxide (`.zshrc.d/050_zoxide.sh`).
   Orphaned file.
8. **`.zshrc.d/050_kubectl.sh:300-301`** — `kjx()` pipes to `fx`, `ky()`
   pipes to `yh`: neither `fx` nor `yh` is installed. `kj()` (jq) works.
9. **`.zshrc.d/050_functions.sh:335-337`** — `rexz` `.lzo` branch calls
   `lzop`, which is not installed (`zstd`, `lz4`, `7z` are present).

## Proposed change

For each item either delete the alias/file (1, 2, 6, 7, and 5 if xdebug is
gone for good) or fix/reinstate the dependency:

- `server`: `alias server='open http://localhost:8000 && python3 -m http.server'`
- `vscode`/`vsc`: drop, or install the `visual-studio-code` cask (note
  `bin/theme.rs` also has a VSCode changer — see the theme.rs todo).
- `kjx`/`ky`: add `fx` and `yh` to the Brewfile, or drop the two functions.
- `rexz`: add `lzop` to the Brewfile or remove the `.lzo` case.
