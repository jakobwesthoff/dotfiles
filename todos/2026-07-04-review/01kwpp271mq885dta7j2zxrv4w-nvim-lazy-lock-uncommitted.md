# nvim: uncommitted lazy-lock.json bump (mini.ai) — commit it

**Area**: nvim
**File**: /Users/jakob/dotfiles/.config/nvim/lazy-lock.json (uncommitted working-tree change)

## Current state

`git diff` shows a single-line change:

```diff
-  "mini.ai": { "branch": "main", "commit": "d73c36349aa7b0bab5f77ad71701a1d42211a1df" },
+  "mini.ai": { "branch": "main", "commit": "cb20f298ebf5ae91924cd0c6c310712de2ef4086" },
```

## Assessment

The change looks intentional (routine `:Lazy update`), not accidental:

- The installed plugin matches the new pin exactly:
  `git -C ~/.local/share/nvim/lazy/mini.ai log -1` →
  `cb20f298... 2026-06-29 fix(ai): make empty span cover nothing`.
- The lockfile was last committed 2026-06-29 (commit 6cc82aa "Remove
  obsidian integrate ntropy"); the upstream mini.ai commit is dated the same
  day, so the update happened after that commit.

Until committed, a fresh `:Lazy restore` on another machine would install
the old mini.ai commit, diverging from what this machine actually runs.

## Proposed change

Commit the lazy-lock.json bump (a one-line "Update plugin lockfile"-style
commit). No config change is required; the pinned commit is a small upstream
fix already running locally.
