# workflow.md pins outdated GitHub Actions versions

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/workflow.md` — "Complete Workflow" YAML block

**Current state**: The embedded workflow uses:

- `actions/checkout@v4` (both checkout steps)
- `oven-sh/setup-bun@v1`
- `actions/configure-pages@v4`
- `actions/upload-pages-artifact@v3`
- `actions/deploy-pages@v4`

**Problem**: workflow.md itself declares `workflow/generate-pages.yml` in
`jakobwesthoff/project-page-starter` as "the canonical workflow source".
That file was updated on 2026-06-30 (commit e9be969, "Update used workflow
actions to latest versions") and now pins newer versions. The skill
scaffolds workflows with action versions the template repo has already
moved past.

**Grounding**: Local clone at
`/Users/jakob/Development/github/jakobwesthoff/project-page-starter`,
commit e9be969, verified identical to origin HEAD via
`git ls-remote origin HEAD`. Its `workflow/generate-pages.yml` (lines
29-78) pins:

- `actions/checkout@v6`
- `oven-sh/setup-bun@v2`
- `actions/configure-pages@v6`
- `actions/upload-pages-artifact@v5`
- `actions/deploy-pages@v5`

The repo's `GUIDE.md` ("GitHub Actions" section) shows the same versions.
A `diff` between the dotfiles skill and the repo's own skill copy
(`skills/setup-project-page/references/workflow.md`) shows exactly these
five version bumps as the only difference between the two skill trees.

**Proposed change**: Update the five action references in workflow.md's
YAML block to `checkout@v6`, `setup-bun@v2`, `configure-pages@v6`,
`upload-pages-artifact@v5`, `deploy-pages@v5` so the scaffolded workflow
matches the canonical file.
