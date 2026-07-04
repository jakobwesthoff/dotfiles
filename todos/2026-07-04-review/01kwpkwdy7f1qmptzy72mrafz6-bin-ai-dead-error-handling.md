# bin/ai: duplicated `exit_code=$?` makes the claude error branch unreachable

**Area**: shell-env
**File**: /Users/jakob/dotfiles/bin/ai:146-147 (inside `ai_request()`)

## Current state

```bash
  result=$(echo "$content" \
    | claude --print --output-format text \
        ...
        2>"$tmp_err")
  exit_code=$?
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    printf "claude failed (exit %d):\n" "$exit_code" >&2
    ...
```

## Problem

The line `exit_code=$?` appears twice. The first captures the exit status of
the `claude` pipeline; the second captures the exit status of the *first
assignment*, which is always 0. `exit_code` is therefore always 0, the
"claude failed" branch can never run, stderr from claude is silently
discarded, and callers in `main()` (`[ $exit_code -ne 0 ] && exit`) never see
failures either — a failed request just prints an empty answer.

## Grounding

```
$ bash -c 'false; a=$?; a=$?; echo "a=$a"'
a=0
```

The flags the script passes were verified against the installed CLI:
`claude --help` lists `--print`, `--output-format`, `--model`, `--tools`,
`--setting-sources`, and `--system-prompt`, so the invocation itself is fine.

## Proposed change

Delete the duplicated second `exit_code=$?` line.
