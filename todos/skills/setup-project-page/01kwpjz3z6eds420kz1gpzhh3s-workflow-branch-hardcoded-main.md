# Workflow trigger hardcodes `main`; skill never says to adapt it to the default branch

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/workflow.md` — "Complete Workflow" YAML and "Post-Setup" text

**Current state**: The workflow triggers on
`push: branches: [main]` and the Post-Setup text says "The workflow
triggers on pushes to `main` that modify `README.md` or anything in
`docs/pages/`." Neither workflow.md nor SKILL.md instructs the agent to
check the target repository's actual default branch.

**Problem**: On a repository whose default branch is `master` (or
anything else), the scaffolded workflow never triggers on push, and the
skill's own analysis step already gathers git information
(`git remote get-url origin` in SKILL.md step 1) without capturing the
default branch. The failure is silent: the workflow file sits there and
nothing deploys.

**Grounding**: `branches: [main]` quoted from workflow.md in the skill
and confirmed identical in the canonical
`workflow/generate-pages.yml` of `jakobwesthoff/project-page-starter`
(local clone at origin HEAD, commit e9be969). The default branch of a
repo is discoverable read-only via
`git symbolic-ref refs/remotes/origin/HEAD` or
`git remote show origin` (verified locally: the dotfiles repo reports
its default branch through these). GitHub Actions `on.push.branches` is
an exact-match/glob filter per GitHub's workflow-syntax documentation;
a push to `master` does not match `main`.

**Proposed change**: In SKILL.md step 1, add "default branch" to the
extracted facts (via `git symbolic-ref refs/remotes/origin/HEAD`). In
workflow.md, add one sentence after the YAML block: replace `main` in
`branches: [main]` with the repository's default branch if it differs.
