# 000_path.sh carries dead PATH entries from old Linux/macOS setups

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.zprofile.d/000_path.sh

## Current state / Problem

Verified 2026-07-04 — none of these directories exist on this machine:

1. **Line 10**: `export PATH="$PATH:/var/lib/gems/1.8/bin"` — Ruby 1.8 gem
   bin path from a Debian/Ubuntu layout; appended unconditionally.
2. **Line 18**: `export PATH="/usr/local/share/npm/bin:${PATH}"` — npm layout
   of pre-Apple-Silicon Homebrew; **prepended** unconditionally, so a
   nonexistent directory sits in front of every PATH lookup.
3. **Lines 13-15**: `/usr/texbin` block — the directory does not exist;
   guarded by `-d`, so inert. TeX on this machine comes from the Brewfile's
   `texlive` formula, whose binaries are already on PATH via the Homebrew
   prefix (`command -v pdflatex` → `/opt/homebrew/bin/pdflatex`), so the
   block is permanently dead here.
4. **Lines 50-52**: `/snap/bin` block — Linux snapd path in a macOS-targeted
   repo; guarded, inert. Keep only if these files are meant to be shared with
   Linux hosts (nothing else in `.zprofile.d` suggests that; e.g.
   `050_orbstack.sh`, `050_homebrew.sh` are macOS-specific).

Nonexistent PATH entries are not errors, but they cost a stat per lookup miss
and, more importantly, obscure the real PATH composition.

## Grounding

```
$ ls -d /var/lib/gems /usr/local/share/npm /usr/texbin /snap
ls: cannot access ... No such file or directory  (all four)
```

(gnubin/findutils handling in the same file is covered by the
stage_for_storage.sh todo; `$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin`
and `gnuman` both exist and work.)

## Proposed change

Delete entries 1 and 2. Delete the `/usr/texbin` block. Decide whether Linux
support (`/snap/bin`) is a goal; if not, delete that block too.
