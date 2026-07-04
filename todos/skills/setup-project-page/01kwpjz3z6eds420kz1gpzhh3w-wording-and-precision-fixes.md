# Grouped wording and precision fixes

**Skill**: setup-project-page
**Files**: sections.md, theme-and-readme.md, config.md, SKILL.md under
`/Users/jakob/dotfiles/.claude/skills/setup-project-page/`

Small items, none warranting a standalone todo. Generator facts cite
`jakobwesthoff/project-page-starter` at origin HEAD (commit e9be969,
local clone at
`/Users/jakob/Development/github/jakobwesthoff/project-page-starter`).

## 1. sections.md — "Source" tab example omits dependency install

The quick-start template's Source tab shows:

```bash
git clone https://github.com/user/repo
cd repo
npm run build
```

`npm run` executes a package.json script and does not install
dependencies, so this sequence fails in a fresh clone for any project
with build-time dependencies. As a template it teaches visitors broken
from-source instructions. Fix: insert `npm install` before
`npm run build` (the guide's equivalent example uses
`cargo build --release`, which resolves dependencies itself, so only the
npm variant is affected).

## 2. theme-and-readme.md — "Markers MUST be on their own lines" overstates enforcement

Listed under "Rules" as if the generator required it. Actual behavior
(`generator/lib/readme.ts`): extraction is character-offset based
(`indexOf` of the exact marker strings, slice between them, `trim`).
Markers on shared lines do not error; instead, same-line text adjacent
to a marker silently leaks into or out of the extracted region. Keep the
own-line guidance but state the real behavior so a debugging agent knows
what a violation looks like (garbled boundary content, not an error).

## 3. config.md — state actual behavior for the two malformed-section cases

- "NEVER specify both `file` and `source`": when both are present the
  generator uses `source: readme` and silently ignores `file`
  (`buildSections()` in `generator/bin/generate.ts` checks
  `section.source === "readme"` first).
- A section with **neither** key does not error either: the generator
  logs `<id>: skipped (no source)` and omits the section from the page
  (same function, final `else` branch).

Adding these one-line behavior notes makes both anti-patterns
verifiable and tells an agent what symptom to look for.

## 4. SKILL.md step 3 — empty `docs/pages/assets/` will not survive a commit

Step 3 creates `docs/pages/assets/` unconditionally. Git does not track
empty directories, so for projects without demo assets the directory
vanishes at commit time. This is harmless at build time
(`copyAssets()` in `generator/bin/generate.ts` treats a missing assets
directory as empty via `readdir(...).catch(() => [])`), but the
scaffold silently differs from what was "created". Fix: either create
`assets/` only when assets are actually added (demo videos, logos), or
place a `.gitkeep` in it — `copyAssets()` explicitly skips `.gitkeep`
files when copying, so the placeholder never reaches the published site.
