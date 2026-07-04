# initial_macos_setup.sh: existing-clone path skips checkout_dependencies.sh and stow

**Area**: shell-env
**File**: /Users/jakob/dotfiles/initial_macos_setup.sh:144-154 (also 303-311)

## Current state

```bash
if [ -d "$HOME/dotfiles" ]; then
	ok "Dotfiles already cloned"
else
	info "Cloning dotfiles..."
	git clone git@github.com:jakobwesthoff/dotfiles.git dotfiles
	pushd "$HOME/dotfiles"
	./checkout_dependencies.sh
	stow .
	popd
	ok "Dotfiles cloned and stowed"
fi
```

## Problem

`checkout_dependencies.sh` (zgen, colorizer, prettytable — all sourced
unconditionally by `.zshrc`) and `stow .` only run in the fresh-clone branch.
On a machine where `~/dotfiles` already exists (e.g. cloned manually before
running the setup script, which is exactly the flow the README describes:
"run the following script after checkout"), the script reports "ok" and never
checks out shell dependencies nor stows the tree. The resulting shell then
fails at `.zshrc:64` (`source ~/.zgen/zgen.zsh`) on every start.

Both operations are idempotent (`checkout_or_update` pulls when the target
exists; stow is restow-safe with `-R`), so there is no reason to gate them on
the clone.

Secondary observation in the same file: the sudo keep-alive guard at line 305

```bash
if ! pgrep -f "sudo -n true.*sleep 60" &>/dev/null; then
```

can never match — the background keep-alive is a `while` loop inside the
running bash process, so no process carries a command line matching
`sudo -n true.*sleep 60`. The guard is dead code (harmless: the script only
reaches this point once per run).

## Grounding

- README.md:24-31 documents the run-after-checkout flow.
- `.zshrc:64,66-73` sources `~/.zgen/zgen.zsh`, `~/.colorizer/...`,
  `~/.prettytable/...` without existence guards (except the prettytable
  old/new fallback).
- shellcheck reports no issues for initial_macos_setup.sh (verified).

## Proposed change

Move `./checkout_dependencies.sh` and `stow .` (or `stow -R .`) out of the
else-branch so they always run after the clone-or-skip step. Either delete
the dead pgrep guard or drop it in favor of unconditionally starting the
keep-alive loop.
