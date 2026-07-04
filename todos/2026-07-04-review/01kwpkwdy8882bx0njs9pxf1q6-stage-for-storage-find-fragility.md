# stage_for_storage.sh mixes BSD `find -s` with GNU stat/sort — breaks if GNU findutils gets installed

**Area**: shell-env
**File**: /Users/jakob/dotfiles/bin/stage_for_storage.sh:49 (also 5, 71)
**Related**: /Users/jakob/dotfiles/.zprofile.d/000_path.sh:44-47

## Current state

```bash
find -s "${src}" -type f -not -iname ".*" |sort -Vs >"${list_tmp}"
...
file_size="$(stat --printf="%s" "${file}")"
```

`-s` (sorted traversal) is a BSD find flag; `stat --printf` and `sort -Vs`
are GNU options. The script currently works because:

- GNU coreutils' gnubin is on PATH (provides GNU `stat`/`sort`), and
- GNU findutils is **not** installed, so `find` resolves to BSD
  `/usr/bin/find` (verified: `/opt/homebrew/opt/findutils` does not exist).

## Problem

`.zprofile.d/000_path.sh:44-47` explicitly prepends
`$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin` to PATH whenever findutils is
installed ("Prefer gnu find, locate and xargs over bsd tools"). The moment
findutils lands on the machine, `find -s` hits GNU find, which has no `-s`
flag, and the script dies at the scanning step. The script's correctness
depends on findutils staying uninstalled while the profile actively prepares
for the opposite.

## Grounding

- `ls -d /opt/homebrew/opt/findutils/libexec/gnubin` → No such file or
  directory (2026-07-04), so today `find` = BSD find and `-s` works.
- BSD find(1) documents `-s` (traverse lexicographically); GNU find has no
  such option — with GNU find, `-s` is parsed as an unknown predicate and the
  invocation errors out.
- Brewfile contains `coreutils` but not `findutils`, matching the current
  state.

## Proposed change

Make the pipeline shell-agnostic: drop `-s` and let the existing
`sort -Vs` do the ordering (it already sorts the whole list anyway):

```bash
find "${src}" -type f -not -iname ".*" | sort -Vs >"${list_tmp}"
```

`-s` only guarantees traversal order, which is redundant given the explicit
sort. This removes the BSD-only dependency entirely.
