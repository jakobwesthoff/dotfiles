# .stow-local-ignore misses repo-level tooling files — they get symlinked into $HOME

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.stow-local-ignore

## Current state

The custom section of the ignore list is:

```
\.DS_Store
^/macos.*$
^/iterm2.*$
^/checkout_dependencies\.sh$
```

(plus README/LICENSE/git defaults re-declared above it.)

## Problem

1. **Repo-management files are stowed into $HOME.** `Brewfile`,
   `initial_macos_setup.sh`, `update-brewfile-from-system`, and `todos/` are
   not ignored. Two of them are already linked from an earlier `stow .` run:

   ```
   $ ls -la ~/Brewfile ~/initial_macos_setup.sh
   ~/Brewfile -> dotfiles/Brewfile                       (Mar  6  2025)
   ~/initial_macos_setup.sh -> dotfiles/initial_macos_setup.sh
   ```

   `~/update-brewfile-from-system` and `~/todos` do not exist yet, so the
   next `stow .` will create them (stow has not been re-run since those were
   added). `update-brewfile-from-system` also only works when run from the
   directory containing the Brewfile (it checks `$PWD`), so a `$HOME` symlink
   to it is doubly pointless.

2. **Stale patterns.** `^/macos.*$` and `^/iterm2.*$` match nothing — no file
   or directory starting with `macos` or `iterm2` exists in the repo root
   (verified with `ls -la /Users/jakob/dotfiles`).

## Proposed change

- Add ignore patterns for `^/Brewfile$`, `^/initial_macos_setup\.sh$`,
  `^/update-brewfile-from-system$`, `^/todos$`.
- Remove the existing `~/Brewfile` and `~/initial_macos_setup.sh` symlinks
  (`stow -R .` after updating the ignore file, or delete them manually).
- Drop the dead `^/macos.*$` and `^/iterm2.*$` patterns.
