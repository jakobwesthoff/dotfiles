# 050_ekkocli.sh regenerates completions on every shell start — 70% of interactive startup time

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.zshrc.d/050_ekkocli.sh

## Current state

```zsh
if [ -e "${HOME}/.local/bin/ekkocli" ]; then
    source <(~/.local/bin/ekkocli --zsh-completion)
fi
```

`~/.local/bin/ekkocli` is a symlink to a local dev checkout
(`~/Development/gitlab/ekkogmbh/ekkocli/ekkocli`), so this runs on this
machine for every interactive shell.

## Problem

Spawning `ekkocli --zsh-completion` and sourcing its output takes ~0.28s of a
~0.40s total warm interactive startup, i.e. roughly 70% of shell startup
time. Every other startup component is comparatively negligible.

## Grounding

Measured 2026-07-04 with timestamped xtrace
(`PS4='+%D{%s.%6.} %N:%i> ' zsh -xic exit`), largest gaps:

```
0.282s after: /Users/jakob/.zshrc.d/050_ekkocli.sh:2> source /dev/fd/14
0.035s after: /Users/jakob/.zshrc:91> fastfetch
0.010s after: /Users/jakob/.zshrc.d/050_worktrunk.sh:2> wt config shell init zsh
```

Warm full startup, three runs of `/usr/bin/time zsh -ic exit`:
0.42s / 0.40s / 0.40s real.

## Proposed change

Cache the generated completion the same way `.zshrc.d/050_kubectl.sh` already
does for kubectl (write to `${XDG_CACHE_HOME:-$HOME/.cache}/ekkocli/_ekkocli`,
source the cached file, regenerate in the background with `&|`). That removes
~0.28s from every shell start while keeping completions fresh.
