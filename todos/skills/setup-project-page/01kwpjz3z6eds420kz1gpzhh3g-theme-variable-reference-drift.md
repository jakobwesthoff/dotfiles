# Theme variable reference: wrong --font-mono default and missing warning-color variables

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/theme-and-readme.md` — "Full Variable Reference" section

**Current state**: The section claims to list "All variables with their
defaults from `templates/styles/theme.css`". Two problems:

1. The Typography table gives `--font-mono` as
   `"JetBrains Mono", ui-monospace, ...monospace`.
2. The three warning-color variables are absent from the tables entirely.

**Problem**: Both claims fail against the declared source file. An agent
following the skill would report a wrong default font stack to users and
would not know the warning palette variables exist (they drive the
`.callout-warning` component, so a light-theme or brand re-theme that
misses them leaves warning callouts in the default amber).

**Grounding**: `templates/styles/theme.css` in
`jakobwesthoff/project-page-starter` (local clone at origin HEAD,
commit e9be969):

- Line 34: `--font-mono: Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace;`
  (no JetBrains Mono, no ui-monospace).
- Lines 8-11:

  ```css
  /* Warning colors - Amber palette */
  --color-warning-rgb: 245, 158, 11;
  --color-warning: rgb(var(--color-warning-rgb));
  --color-warning-subtle: rgba(var(--color-warning-rgb), 0.1);
  ```

All other variables and defaults in the skill's tables match theme.css
(verified line by line). Note: the repo's `GUIDE.md` "All CSS variables"
section carries the same stale JetBrains Mono value, which is likely
where the skill inherited it; theme.css is authoritative.

**Proposed change**:

1. Correct the `--font-mono` default to
   `Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace` (or elide
   as `Consolas, Monaco, ...monospace`).
2. Add a "Warning colors" table with the three `--color-warning*`
   variables and their defaults, noting they style `.callout-box`
   warning variants.
