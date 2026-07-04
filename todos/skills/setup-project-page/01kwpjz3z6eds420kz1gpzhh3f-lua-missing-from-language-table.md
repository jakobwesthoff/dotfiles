# Lua missing from the supported syntax-highlighting languages table

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/sections.md` — "Supported Syntax Highlighting Languages" table

**Current state**: The table lists exactly: `language-bash` (aliases
`shell`, `sh`, `zsh`), `language-json`, `language-yaml`, `language-toml`,
`language-typescript`, `language-javascript`, `language-rust`,
`language-go`, and states "Unrecognized languages render as plain text."

**Problem**: The generator gained Lua support on 2026-06-30 and the
skill's table does not reflect it. A page scaffolded for a Lua project
(e.g. a Neovim plugin) would render its code blocks unhighlighted because
the skill steers authors away from `language-lua`.

**Grounding**: `generator/lib/highlighting.ts` in
`jakobwesthoff/project-page-starter` (local clone at origin HEAD,
commit e9be969), line 7:

```typescript
const SUPPORTED_LANGS = ["bash", "json", "yaml", "toml", "typescript", "javascript", "rust", "go", "shell", "sh", "zsh", "lua"];
```

Added by commit db9e4d6 ("Add Lua to supported syntax-highlighting
languages", 2026-06-30). The alias normalization in the same file maps
only `sh`/`shell`/`zsh` to `bash`; Lua has no aliases. The plain-text
fallback claim is confirmed by the `escapeHtml(code)` fallback in
`highlightCode()`. Note: the repo's own `GUIDE.md` and the repo's skill
copy also still lack Lua in their tables, so do not "verify" against
those; `highlighting.ts` is the source of truth.

**Proposed change**: Add a `language-lua` row (no aliases) to the table
in sections.md.
