# Section id rule is self-contradictory; actual invariant is anchor-based

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/sections.md` — "General Rules" bullet 2 and last "Anti-Patterns" bullet

**Current state**: General Rules state: "The outermost element needs an
`id` matching the section's `id` in config.yaml (except hero which uses
its class)". The final anti-pattern says: "NEVER put the section `id` on
the hero element — the hero uses its class for styling; other sections
(demo, quickstart) do need `id` attributes for anchor links".

**Problem**: The stated rule contradicts the skill's own templates and
misstates the mechanism:

- The skill's `highlights.html` and `footer.html` templates have **no**
  `id` attribute, yet neither is "hero", so following the General Rules
  literally conflicts with copying the provided templates.
- The real invariant is about anchors, not styling: the generator injects
  file-based section HTML verbatim (no id is added or checked), and the
  navbar renders `<a href="#{{ section.id }}">` for every section with
  `nav: true`. So an `id` is required exactly for sections that are
  linked to (`nav: true`, or targeted by an in-page `href="#..."` such as
  the hero button linking to `#quickstart`). Sections with `nav: false`
  and no inbound anchor need no id, and an id on the hero is harmless
  rather than forbidden-for-styling-reasons.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `templates/partials/navbar.njk` lines 9-13: nav links are
  `href="#{{ section.id }}"` for sections with `nav: true`.
- `templates/index.njk` lines 9-19: file-based sections are emitted as
  `{{ section.html | safe }}` verbatim; only `source: readme` sections
  get a generator-provided wrapper `<section id="{{ section.id }}" class="docs">`.
- The skill's own templates in sections.md: hero
  (`<section class="hero">`, no id), highlights
  (`<section class="highlights">`, no id), footer
  (`<footer class="footer">`, no id), demo (`id="demo"`), quickstart
  (`id="quickstart"`). The config.md example marks demo and quickstart
  `nav: true` and hero/highlights/footer `nav: false`, matching the
  anchor-based rule exactly.
- The repo's `GUIDE.md` even puts `id="hero"`, `id="highlights"`, and
  `id="footer"` on its example sections, confirming ids on non-nav
  sections are legal.

**Proposed change**: Replace both statements with the actual invariant:
"Any section that is linked to must carry a matching `id` on its
outermost element: every section with `nav: true`, plus any section
targeted by an in-page link (e.g. `#quickstart` from the hero CTA).
Sections with `nav: false` and no inbound links (hero, highlights,
footer in the standard layout) do not need an id. `source: readme`
sections get their id from the generator automatically."
