# Icon set not stated as complete; unknown icon names fail silently

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/sections.md` — hero.html "Icons" note

**Current state**: "Use `<i data-icon="download"></i>` or
`<i data-icon="github"></i>` — these are replaced at build time with
inline SVGs." The sentence reads as two examples, not as the complete
set, and nothing describes what happens with other names.

**Problem**: `github` and `download` are the only icons that exist. An
agent adapting the templates (e.g. `data-icon="star"` for a different
CTA) gets no build error: the generator prints a console warning and
leaves the `<i>` element in place, which renders as nothing. The icon
silently disappears from the published page.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `templates/icons/` contains exactly two files: `download.svg`,
  `github.svg`. Icon names are derived from filenames
  (`generator/lib/icons.ts` `loadIcons()`).
- `generator/lib/icons.ts` `replaceIcons()`: for an unknown name it
  runs `console.warn(\`Warning: unknown icon "${name}"\`)` and
  `continue`s, leaving the original `<i data-icon="...">` element in
  the output.
- `GUIDE.md` "Icon System" section: "Available icons: `github`,
  `download`." It also confirms icons work in any section HTML, not
  just the navbar.
- `config.md`'s `NavbarButton` type already restricts navbar icons to
  `"github" | "download"`; section HTML has no such type guard.

**Proposed change**: Reword the sections.md icon note to state the set
is exhaustive ("the only available icons are `github` and `download`")
and that unknown names produce no build error, only a build-log warning
and an empty spot on the page.
