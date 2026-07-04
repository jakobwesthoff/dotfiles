# zgen is unmaintained — migrate to its drop-in successor zgenom

**Area**: shell-env
**Files**: /Users/jakob/dotfiles/.zshrc:64,85-87; /Users/jakob/dotfiles/checkout_dependencies.sh:22 (clones tarjoilija/zgen); zgen-load calls in .zshrc.d/050_cd-gitroot.sh, 050_highlight.sh, 980_autosuggest.sh, 990_powerline10k.sh, 999_history-search.sh

## Current state

`.zshrc` sources `~/.zgen/zgen.zsh`; `checkout_dependencies.sh` clones
`https://github.com/tarjoilija/zgen.git` into `~/.zgen`. Five `.zshrc.d`
files register plugins via `zgen load` inside `if ! zgen saved` blocks, and
`.zshrc` finishes with `zgen save`.

## Problem / opportunity

The upstream zgen project (tarjoilija/zgen) is marked unmaintained; its
README points to zgenom (jandamm/zgenom) as the maintained successor, which
is described as fully backwards compatible with the zgen API (a `zgenom`
superset with bugfixes; a migration guide exists in its repo). Staying on an
unmaintained plugin manager means no fixes for future zsh releases.

Sources checked 2026-07-04:
- https://github.com/tarjoilija/zgen (README: unmaintained, recommends zgenom)
- https://github.com/jandamm/zgenom (backwards-compatible successor)

## Proposed change

Low-effort migration since the API is compatible:

1. `checkout_dependencies.sh`: clone `https://github.com/jandamm/zgenom.git`
   (e.g. into `~/.zgenom`).
2. `.zshrc`: source `~/.zgenom/zgenom.zsh` instead of `~/.zgen/zgen.zsh`.
3. The existing `zgen load` / `zgen saved` / `zgen save` calls keep working
   under zgenom; optionally rename to the `zgenom` command forms when
   touching those files anyway.

This is not urgent — the current setup works — but it is the cleanest point
to also pick up zgenom's `zgenom clean`/`zgenom update` maintenance commands.
