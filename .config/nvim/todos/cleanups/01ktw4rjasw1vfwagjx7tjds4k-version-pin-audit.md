# Audit version/branch/tag pins: document or remove undocumented ones

Created: 2026-06-11, on request after the full-config code review
(`docs/code-review-2026-06-11.md`): note every place a version is
pinned without a stated reason.

## Complete pin inventory (all specs read 2026-06-11)

| Spec | Pin | Reason stated in spec? | Assessment |
|---|---|---|---|
| `blink-cmp.lua:4` | `version = "v1.*"` | yes — "use a release tag to download pre-built binaries" (line 3) | justified, keep |
| `rustaceanvim` (`lsp.lua:197`) | `version = "^5"` | only "-- Recommended" | **stale** — handled by `todos/plugin-updates/*-rustaceanvim-bump-v9.md`; after the bump, keep a major pin (`^9`) and replace the comment with the actual reason (avoid surprise breaking majors) |
| `crates.lua:4` | `tag = "stable"` | **no** | undocumented — see below |
| `treesitter.lua:3` | `branch = "main"` | implicitly — the config comments (treesitter.lua:37-39) are written for the main-branch API | justified (the rewrite branch; master is frozen), add one explicit comment line |
| `harpoon.lua:3` | `branch = "harpoon2"` | no comment, but harpoon2 is the current rewrite and the keymaps use its API (`harpoon:list()` etc.) | justified, optionally one comment line |
| `setup.lua:8` | lazy.nvim bootstrap clone `--branch=stable` | standard bootstrap snippet | fine |
| `lazy-lock.json` | commit pins for everything | n/a | that's the lockfile working as intended |

No other spec carries `version`, `tag`, `branch`, `commit`, or `pin`
keys (grep across `lua/mrjakob/plugins/`).

## The one real item: crates.nvim `tag = "stable"`

`tag = "stable"` pins to upstream's floating "stable" tag (resolves to
v0.7.1 on the installed copy — `git tag --points-at HEAD`). Effect
under lazy.nvim: updates only land when upstream moves that tag, and
`:Lazy update` follows it silently. Nothing in the spec says why
stable-channel-only was chosen over default branch tracking.

Decide and encode:

- **Keep the stable channel:** add a comment stating the intent
  ("follow upstream stable releases only"), so the pin reads as a
  decision instead of leftover.
- **Or drop the pin** and track the default branch like the majority of
  this config's plugins, with `lazy-lock.json` providing
  reproducibility.

## Policy observation (for the same decision)

The config currently mixes three update philosophies: floating major
pins (blink `v1.*`, rustaceanvim `^N`), channel tag (crates `stable`),
and untracked-latest + lockfile (everything else). That mix is fine —
binary-shipping and fast-breaking plugins deserve tighter pins — but
each tightened pin should carry its reason in a comment, which today
only blink.cmp does.

## Basis

All pins from direct reads of the specs cited; crates tag resolution
and installed versions from git commands against
`~/.local/share/nvim/lazy/` (2026-06-11).
