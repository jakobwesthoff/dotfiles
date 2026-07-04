# Minor robustness nits across shell env (grouped)

**Area**: shell-env
**Files**: various (each item lists its exact location)

Small, same-class findings that individually don't warrant a file. All
verified 2026-07-04.

## 1. `${FUNCNAME[0]}` is a bash-ism — usage messages print empty names

`.zshrc.d/050_functions.sh:100` (`wait_for`) and `:127` (`wait_for_port`):

```zsh
echo "usage: ${FUNCNAME[0]} <hostname>"
```

zsh has no `FUNCNAME`; verified: `zsh -c 'f() { echo "usage: ${FUNCNAME[0]} x" }; f'`
prints `usage:  x`. Use `$0` (inside a zsh function it is the function name)
or `$funcstack[1]`.

## 2. EDITOR capture of `which` failure text

`.zprofile.d/050_editor.sh`:

```zsh
export EDITOR=$(which nvim)
```

In zsh, `which missing` prints `missing not found` **to stdout**; verified:
`EDITOR=$(which nonexistentcmd)` yields `EDITOR=[nonexistentcmd not found]`.
Works today because nvim is installed, but on a fresh machine EDITOR becomes
garbage instead of empty. Safer: `export EDITOR=nvim` guarded by
`command -v nvim >/dev/null`.

## 3. pushnotify shellcheck findings

`bin/pushnotify:102` — SC2181: `RESPONSE=$(...)` followed by
`if [[ $? -eq 0 ]]`; check the command directly
(`if RESPONSE=$("${CURL_CMD[@]}"); then`). `bin/pushnotify:71` — SC1090
(non-constant source): add `# shellcheck source=/dev/null` above
`source "$CONFIG_FILE"`.

## 4. stage_for_storage.sh SC2016

`bin/stage_for_storage.sh:5` — shellcheck info SC2016 on the single-quoted
gsed program containing `${}`. The non-expansion is intentional (it is a
regex escaping table); silence with a targeted
`# shellcheck disable=SC2016` so the script is shellcheck-clean.

## 5. `.zshrc.d/050_bun.sh` hardcodes the user path

```zsh
[ -s "/Users/jakob/.bun/_bun" ] && source "/Users/jakob/.bun/_bun"
```

Its `.zprofile.d` counterpart already uses `$HOME` (`BUN_INSTALL="$HOME/.bun"`).
Use `"$HOME/.bun/_bun"` for consistency.

## Explicitly checked and fine (no action)

- `local` at `.zshrc` top level: valid in zsh (verified, no error).
- `ulimit -n 10240 unlimited` (050_ulimit.sh): accepted by zsh, sets 10240.
- `which -s dircolors` (050_dircolors.sh): valid zsh `whence -s` usage;
  "not found" output goes to stdout and is discarded by the redirect.
- shellcheck: `bin/ai`, `bin/yabai_recording`, `bin/hide_desktop`,
  `bin/show_desktop`, `initial_macos_setup.sh`, `update-brewfile-from-system`
  all pass with no findings.
