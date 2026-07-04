# Brewfile hygiene: duplicate `fd` entry and two unused tap declarations

**Area**: shell-env
**File**: /Users/jakob/dotfiles/Brewfile

## Current state / Problem

1. **`brew "fd"` is declared twice** — line 25 (Shell & Terminal section) and
   line 43 (Core CLI Utilities section):

   ```
   $ grep -n 'brew "fd"' Brewfile
   25:brew "fd"
   43:brew "fd"
   ```

2. **`tap "yt-dlp/taps"` (line 9) is unused.** No Brewfile entry references
   a `yt-dlp/taps/...` formula. The installed yt-dlp comes from homebrew/core:

   ```
   $ jq -r '.source.tap' /opt/homebrew/Cellar/yt-dlp/*/INSTALL_RECEIPT.json
   homebrew/core
   ```

   `brew "yt-dlp", args: ["HEAD"]` (line 153) therefore builds core's HEAD;
   the tap declaration contributes nothing.

3. **`tap "xorpse/formulae"` (line 8) is unused.** No Brewfile entry
   references it, and no installed keg originates from it:

   ```
   $ grep -l xorpse /opt/homebrew/Cellar/*/*/INSTALL_RECEIPT.json
   (no matches)
   ```

Note: `update-brewfile-from-system` (by design, see its header comment) never
removes taps, so these will not clean themselves up.

## Proposed change

- Delete one of the two `brew "fd"` lines (keep the one in Core CLI
  Utilities).
- Delete `tap "yt-dlp/taps"` and `tap "xorpse/formulae"` unless there is a
  deliberate reason to keep the taps around for manually installed software
  (nothing installed currently traces back to either).

## Correction (second pass)

Three line references above are wrong; the substance of every claim was
re-verified and holds (2026-07-04, `grep -n` against the committed
Brewfile, receipts re-checked):

- `tap "xorpse/formulae"` is **line 12**, not line 8.
- `tap "yt-dlp/taps"` is **line 13**, not line 9.
- `brew "yt-dlp", args: ["HEAD"]` is **line 128**, not line 153.

The `brew "fd"` line numbers (25 and 43) are correct.
