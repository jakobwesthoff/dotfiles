# Custom domains: CNAME file is ignored for Actions deployments (optional Post-Setup note)

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/workflow.md` — "Post-Setup" section

**Current state**: Post-Setup covers only enabling Pages (Settings >
Pages, source "GitHub Actions"). Custom domains are not mentioned
anywhere in the skill.

**Problem / opportunity**: Verdict from grounding this: the silence is
*not* a scaffold gap. For the deployment method this skill sets up, a
custom domain requires no change to any generated file; it is
configured entirely in repository settings plus DNS. The one failure
mode worth a sentence is an agent following the widespread
branch-publishing folklore and adding a `CNAME` file to the artifact
(e.g. into `docs/pages/assets/`), which does nothing for
Actions-deployed sites.

**Grounding**: GitHub Docs, "Managing a custom domain for your GitHub
Pages site"
(docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site,
fetched 2026-07-04):

- Verbatim: "If you are publishing from a custom GitHub Actions
  workflow, no `CNAME` file is created, and any existing `CNAME` file
  is ignored and is not required."
- Configuration is Settings > Pages > "Custom domain" plus DNS records:
  a CNAME record pointing the subdomain to `USERNAME.github.io` for
  subdomains; for apex domains, A records
  `185.199.108.153`/`.109.153`/`.110.153`/`.111.153` and AAAA records
  `2606:50c0:8000::153` through `2606:50c0:8003::153` (or ALIAS/ANAME
  to `USERNAME.github.io`).
- The `CNAME`-file-commit behavior applies only to branch publishing:
  "If you are publishing your site from a branch, this will create a
  commit that adds a `CNAME` file directly to the root of your source
  branch."

**Proposed change**: Optional, low priority. Add one sentence to
Post-Setup: a custom domain is configured in Settings > Pages plus DNS
records and needs no `CNAME` file — with this Actions-based deployment,
GitHub ignores `CNAME` files in the artifact.
