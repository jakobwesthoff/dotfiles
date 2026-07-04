# update-brewfile-from-system: two fidelity gaps found in the logic audit

**Area**: shell-env
**File**: /Users/jakob/dotfiles/update-brewfile-from-system:102 (jq filter) and :388-390 (atomic replace)
**Related todo**: 01kwpkwdy8882bx0njs9pxf1q4-stow-ignore-gaps.md (the `~/Brewfile` symlink involved in item 2)

Second-pass end-to-end logic audit of the reconciliation pipeline. The
overall design is sound (see "Verified healthy" below); two concrete gaps
remain.

## 1. Formulae that are both on-request AND a dependency are dropped from the inventory

`scan_formulae` filters receipts with:

```bash
jq -r '
  select(.installed_on_request == true and (.installed_as_dependency != true))
  ...
```

Homebrew sets **both** flags when a formula was pulled in as a dependency
and *also* explicitly installed by the user (or vice versa). The
`installed_as_dependency != true` clause therefore excludes explicitly
requested formulae whenever something else depends on them. The function's
own comment (lines 89-92: "keep the formulae that were installed on
request (not merely as a dependency)") describes the correct semantics;
the implementation is stricter than the comment.

Consequences:

- Such a formula **absent from the Brewfile** never appears in the
  checklist at all — it cannot be added, and the Brewfile silently loses
  explicitly requested packages.
- Such a formula **present in the Brewfile** is annotated "not installed"
  in the dialog, inviting an incorrect removal.

### Grounding (2026-07-04, this machine)

```
$ jq -r 'select(.installed_on_request == true and .installed_as_dependency == true)
         | input_filename' /opt/homebrew/Cellar/*/*/INSTALL_RECEIPT.json
ttyd
webp

$ brew bundle dump --file=- | grep -E '"(ttyd|webp)"'
brew "webp"
brew "ttyd"
```

`brew bundle dump` (Homebrew's own notion of what belongs in a Brewfile)
includes both; the script's inventory omits both. Neither is currently in
the Brewfile, so both are invisible to the tool today.

### Proposed change

Drop the `installed_as_dependency` clause:

```bash
select(.installed_on_request == true)
```

`installed_on_request == true` already means "not merely a dependency".

## 2. Running from $HOME via the stow-created symlink forks the Brewfile

`apply_plan` replaces the file with:

```bash
local tmp="$BREWFILE.tmp.$$"
printf '%s\n' "${out[@]}" >"$tmp"
mv "$tmp" "$BREWFILE"
```

`~/Brewfile` is a symlink to `dotfiles/Brewfile` (created by an earlier
`stow .`; verified `~/Brewfile -> dotfiles/Brewfile`). The precondition
check `[[ -f $BREWFILE ]]` passes for a symlink, so running the script
from `$HOME` works — but `mv` replaces the *symlink itself* with a regular
file: the repo's Brewfile keeps its old content and `~/Brewfile` becomes a
divergent copy that the next `stow .` conflicts on.

Demonstrated with a symlinked file in a scratch directory: after
`mv tmp link-name`, the link was a regular file with the new content and
the link target still held the original content.

### Proposed change

Resolve the symlink before replacing, e.g. set
`BREWFILE=$(readlink -f Brewfile 2>/dev/null || echo Brewfile)` in
`main()` after the existence check (GNU readlink is available via the
coreutils gnubin). Removing the `~/Brewfile` symlink per the stow-ignore
todo removes the trigger, but the script-side fix keeps `mv` safe for any
future symlinked Brewfile.

## Verified healthy (no action)

- jq `input_filename` pairing across many receipt files is correct
  (tested with crafted multi-file input, filtered and unfiltered).
- Cask inventory: all 62 Caskroom entries on this machine have
  `.metadata/INSTALL_RECEIPT.json`, every one with
  `installed_on_request: true` — the "casks are always explicit"
  assumption holds.
- Versioned names (`helm@3`, `python@3.14`, `istat-menus@6`) match keg
  and Caskroom directory names, so the `type/short-name` keying works.
- Tap-qualified Brewfile entries (`azure/kubelogin/kubelogin`) pair with
  their keg via the short-name rule as documented.
- HEAD detection (`yt-dlp`), removal of `, args:` lines, tap insertion
  point, "Unsorted" banner reuse, and cancel-leaves-file-untouched were
  all traced through and behave as the header comment describes.
