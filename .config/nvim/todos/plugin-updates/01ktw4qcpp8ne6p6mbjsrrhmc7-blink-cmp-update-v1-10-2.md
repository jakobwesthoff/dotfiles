# Update blink.cmp v1.10.1 → v1.10.2

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). Trivial maintenance item.

## Situation

- Spec: `lua/mrjakob/plugins/blink-cmp.lua:4` pins `version = "v1.*"`
  (with the documented reason at line 3: release tags ship pre-built
  binaries for the fuzzy matcher).
- Installed: v1.10.1 (git describe of
  `~/.local/share/nvim/lazy/blink.cmp`, checked 2026-06-11).
- Latest upstream tag at the same time: v1.10.2 (git ls-remote tags,
  sorted; no v2 exists).

The `v1.*` pin already permits v1.10.2; the installed copy simply
hasn't been updated. This is exactly what `:Lazy update` resolves.

## Action

1. `:Lazy update blink.cmp` (or a full `:Lazy update` if doing the
   rustaceanvim/mason updates at the same time —
   `todos/plugin-updates/*-rustaceanvim-bump-v9.md`,
   `todos/plugin-updates/*-mason-org-repo-rename.md`).
2. Smoke-test completion: open a Lua file, trigger the menu, accept
   with `<C-Y>`/`<C-Z>`, check ghost text and signature help still
   appear.
3. Commit the resulting `lazy-lock.json` change.

## Basis

Installed plugin git state and upstream tag listing, both checked
2026-06-11 during the review.
