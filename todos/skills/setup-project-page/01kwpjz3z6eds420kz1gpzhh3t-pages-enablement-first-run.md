# workflow.md: first run fails when GitHub Pages is not yet enabled; ordering and error not documented

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/workflow.md` — "Post-Setup" section

**Current state**: Post-Setup says: "After adding the workflow file,
enable GitHub Pages in the repository: 1. Go to Settings > Pages,
2. Under 'Build and deployment', select GitHub Actions as the source."
It does not say what happens if the workflow runs before that manual
step, nor that the push that adds `docs/pages/` will itself trigger the
workflow (the `paths` filter matches `docs/pages/**`).

**Problem**: The natural sequence (commit + push the scaffold, then go
to Settings) makes the very first workflow run race the manual
enablement. If Pages is not yet enabled when the `Setup Pages` step
runs, the run fails, and the error is confusing without context. Users
then need to know the failed run can simply be re-run (or re-triggered
via `workflow_dispatch`) after enabling Pages; the skill covers none of
this.

**Grounding**:

- `actions/configure-pages` `action.yml`
  (raw.githubusercontent.com/actions/configure-pages/main/action.yml):
  the `enablement` input defaults to `'false'` and its description
  states: "Try to enable Pages for the repository if it is not already
  enabled. This option requires a token other than `GITHUB_TOKEN` to be
  provided. In the context of a Personal Access Token, the `repo` scope
  or Pages write permission is required." So auto-enablement is not
  available with the workflow's default token, and the manual settings
  step is genuinely required.
- `actions/configure-pages` `src/api-client.js` (main branch): when
  fetching the Pages site fails with enablement disabled, the action
  errors with "Get Pages site failed. Please verify that the repository
  has Pages enabled and configured to build using GitHub Actions, or
  consider exploring the `enablement` parameter for this action."
- The workflow's own trigger (`paths: ['README.md', 'docs/pages/**']`,
  quoted from workflow.md and identical in the canonical
  `workflow/generate-pages.yml` of `jakobwesthoff/project-page-starter`
  at commit e9be969) fires on the scaffold-introducing push itself.

**Proposed change**: Extend Post-Setup with: (a) prefer enabling Pages
(Settings > Pages > source "GitHub Actions") **before** pushing the
scaffold; (b) if the first run already failed with "Get Pages site
failed. Please verify that the repository has Pages enabled...", enable
Pages and re-run the workflow (re-run from the Actions tab or trigger
via `workflow_dispatch`); (c) note that auto-enablement via the
`enablement` input would require a PAT/App token and is intentionally
not used by this workflow.
