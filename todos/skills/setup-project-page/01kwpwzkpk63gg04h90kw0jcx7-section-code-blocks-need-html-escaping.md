# Code blocks in section HTML files silently lose unescaped `<...>` content

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/sections.md` — quick-start.html section ("Key classes" / code-block guidance) and General Rules

**Current state**: The skill shows `code.language-{lang}` blocks in the
quick-start template and says they are syntax-highlighted, but never
states that code content inside section HTML files must be HTML-escaped
(`<` as `&lt;`, `&` as `&amp;`).

**Problem**: Section files are parsed with a real HTML parser before
highlighting. Anything that looks like a tag inside a `<code>` element
becomes an element node and is dropped from the highlighted output with
no error and no warning. Typical victims are CLI placeholder syntax
(`mytool <file>`) and generics (`Vec<String>`) in usage examples. The
published page then shows the command with the placeholder missing.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `generator/lib/highlighting.ts` `highlightHtmlCodeBlocks()`: parses
  the section HTML with linkedom's `parseHTML`, selects
  `code[class*="language-"]`, and highlights `el.textContent` — element
  nodes created from unescaped `<...>` contribute nothing to
  `textContent` and vanish when `el.innerHTML` is replaced.
- Empirically verified against the generator's own pipeline
  (2026-07-04, `bun run` of a test harness importing
  `highlightHtmlCodeBlocks`):
  - `mytool <file> --out result.txt` → surviving text
    `mytool  --out result.txt` (placeholder silently dropped)
  - `let v: Vec<String> = Vec::new();` → `let v: Vec = Vec::new();`
  - `mytool &lt;file&gt; --out result.txt` → intact (renders as
    `mytool <file> --out result.txt` in the browser)
  - `mytool < input.txt` → intact (`<` followed by a space is literal
    text per HTML parsing rules)
- README code is unaffected: `generator/lib/markdown.ts` escapes fenced
  code via `escapeHtml()` before it ever reaches the HTML pass. The
  escaping burden exists only for hand-written section files.

**Proposed change**: Add a rule to sections.md (General Rules or next to
the code-block guidance): inside `<code>` elements in section files,
escape `<` as `&lt;` and `&` as `&amp;`; unescaped angle-bracket content
is parsed as markup and silently dropped from the rendered page. A
matching one-liner in the sections.md Anti-Patterns list ("NEVER put raw
`<placeholder>` text inside code blocks in section files") fits the
existing list style.
