# README docs rendering: GitHub alerts, heading anchors, and table wrapping undocumented

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/theme-and-readme.md` — "README Markers" / "Placement Strategy" sections

**Current state**: The skill says README content between the markers is
"rendered to HTML with syntax-highlighted code blocks at build time" and
that full Markdown is supported ("headings, tables, code blocks with
syntax highlighting, lists, etc."). It documents nothing else about the
rendering.

**Problem / opportunity**: The renderer has three behaviors an author
should exploit (or at least know about) when shaping the README docs
block, all currently invisible to the skill:

1. **GitHub-style alerts become styled callouts.** Blockquotes starting
   with `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, or
   `[!CAUTION]` render as `.callout-box` divs; WARNING and CAUTION get
   the `.callout-warning` variant. Authors can therefore use GitHub
   alert syntax in the README and get matching styled boxes on the
   landing page for free.
2. **Headings get GitHub-compatible anchor ids.** Headings are slugged
   with `marked-gfm-heading-id` (backed by github-slugger), so
   in-README anchor links (`[see config](#configuration)`) keep working
   on the generated page. Side effect worth a caveat: a README heading
   whose slug equals a config section id (e.g. a `## Demo` heading
   producing `id="demo"` while a `demo` section exists) creates a
   duplicate id in the page, and anchor navigation resolves to whichever
   element comes first in the document.
3. **Tables are wrapped** in `<div class="docs-table"><table class="table">`,
   which is why README tables pick up the page styling.

**Grounding**: `generator/lib/markdown.ts` in
`jakobwesthoff/project-page-starter` (local clone at origin HEAD,
commit e9be969):

- Alert handling: `alertPattern = /^<p>\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\n?/i`
  in the `blockquote` renderer; `warningTypes = new Set(["WARNING", "CAUTION"])`;
  emits `<div class="callout-box">` or
  `<div class="callout-box callout-warning">`.
- Heading ids: `md.use(gfmHeadingId())` with an inline comment stating
  README anchor links are authored against GitHub's slugging (feature
  added in commit 4aa0bec "Generate inline header link targets",
  2026-06-30). Section ids come from config.yaml (index.njk renders
  `<section id="{{ section.id }}">` for readme sections), so slug/section
  id collisions are possible; duplicate-id resolution to the first
  element in document order is standard HTML `getElementById`/fragment
  navigation behavior.
- Table wrapping: the `table` renderer returns
  `<div class="docs-table"><table class="table">...</table></div>`.

**Proposed change**: Add a short "What the renderer supports" list to
the README Markers section of theme-and-readme.md covering the three
points above, including the one-sentence collision caveat (avoid README
headings whose slug equals a section id from config.yaml).
