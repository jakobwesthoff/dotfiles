# Code token colors are fixed (github-dark) and do not follow theme variables

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/theme-and-readme.md` — "Full Variable Reference" (Backgrounds table, `--color-bg-code` row)

**Current state**: The variable table lists `--color-bg-code` with
purpose "Code block backgrounds" and presents the variable set as the
theming surface. Nothing states that code *foreground* colors are not
themeable.

**Problem**: Syntax highlighting happens at build time and bakes token
colors in as inline styles. An agent re-theming a page (the template's
own guide demonstrates a full light-theme override including
`--color-bg-code: #f8f8f8`) can change only the background behind
tokens whose colors remain from a dark-background palette. The variable
reference gives no hint that this pairing exists.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `generator/lib/highlighting.ts` line 40:
  `hl.codeToHtml(code, { lang: normalizedLang, theme: "github-dark" })` —
  the theme is hardcoded; only the inner spans are kept, so the code
  background comes from CSS while token colors are inline.
- Verified output (2026-07-04, `bun -e` against the generator):
  `highlightCode("echo hi", "bash")` returns
  `<span style="color:#79B8FF">echo</span><span style="color:#9ECBFF"> hi</span>` —
  literal inline colors, no CSS variables.
- `GUIDE.md` "Syntax Highlighting" section states: "Code blocks in both
  HTML sections and README content are highlighted at build time using
  Shiki with the `github-dark` theme."
- `GUIDE.md` "Light theme" section shows a light override that includes
  `--color-bg-code: #f8f8f8`.

**Proposed change**: Add one sentence to the Full Variable Reference
(at the `--color-bg-code` row or as a note under the Backgrounds
table): code token colors are generated at build time with the fixed
`github-dark` palette and are not affected by theme variables;
`--color-bg-code` changes only the background behind them, so
light-background overrides leave code styled for a dark background.
