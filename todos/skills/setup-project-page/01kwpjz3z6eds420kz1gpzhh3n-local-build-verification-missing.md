# Execution sequence has no local build/verification step and states no prerequisites

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/SKILL.md` — "Execution Sequence" (steps 1-8)

**Current state**: The sequence ends after creating README markers and
the optional GitHub Actions workflow. The scaffolded page is never built
or previewed; the first time the generator runs against the new files is
in CI after a push. The skill also never states that the generator
requires Bun.

**Problem**: All of the generator's failure modes surface only at build
time: missing README markers throw, an empty `sections` array throws, a
missing `file:` target throws on file read, and favicon colors are only
extracted at build time. Without a local run, an agent ships a scaffold
whose first feedback is a failed Pages deployment. The user also gets no
chance to review the page visually before it goes live.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `generator/lib/readme.ts`: throws
  `README.md must contain <!-- docs:start --> and <!-- docs:end --> markers`
  when markers are absent.
- `generator/lib/config.ts` `loadConfig()`: throws on missing `name`,
  `github`, or empty `sections`.
- `generator/bin/generate.ts`: shebang `#!/usr/bin/env bun`, uses
  `Bun.file`/`Bun.write` throughout, so Bun is a hard prerequisite for a
  local run.
- `GUIDE.md` "Running the Generator" documents the exact local
  invocation and output layout; "The output is a self-contained static
  site — open `dist/index.html` in a browser to preview."
- The repo's `AGENTS.md` "Validation Checklist" ends with:
  "Generator runs without errors:
  `bun run generator/bin/generate.ts --docs ./docs/pages --readme ./README.md --output ./dist --templates /path/to/templates`".

**Proposed change**: Add a step 9 "Verify the result" to SKILL.md:
if `bun` is available and the generator repo is cloned locally (or the
user agrees to clone it), run

```bash
bun install            # once, in <starter>/generator/
bun run <starter>/generator/bin/generate.ts \
  --docs docs/pages --readme README.md \
  --output <scratch-dir>/dist --templates <starter>/templates
```

and confirm it completes without errors; offer to open
`dist/index.html` for review. If Bun or the clone is unavailable, state
explicitly that the first validation will happen in CI. Mention Bun as a
prerequisite for local verification near the top of SKILL.md.
