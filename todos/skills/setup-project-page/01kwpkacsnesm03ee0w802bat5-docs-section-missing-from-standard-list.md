# SKILL.md standard section list omits the `docs` (source: readme) section

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/SKILL.md` — step 6 "Create HTML section files"

**Current state**: Step 6 lists the "Standard sections in order" as:
1. `sections/hero.html`, 2. `sections/highlights.html`,
3. `sections/demo.html` (optional), 4. `sections/quick-start.html`,
5. `sections/footer.html`. No documentation section appears in the list.

**Problem**: This contradicts the rest of the skill and can produce a
scaffold where the README markers added in step 7 are dead weight:

- config.md states the "Standard section order: hero, highlights, demo
  (optional), quickstart, **docs**, footer" and its complete example
  includes `- id: docs / source: readme / nav: true`.
- SKILL.md step 7 unconditionally adds README markers, and
  theme-and-readme.md's anti-pattern only covers the reverse direction
  ("MUST NOT forget to add markers when using `source: readme` ... the
  generator will error").
- If an agent builds the sections array from step 6's list, the config
  has no `source: readme` section; the generator then never extracts the
  README (extraction runs per-section in `buildSections()` of
  `generator/bin/generate.ts`, only for sections with
  `source === "readme"`), no error is raised, and the markers added in
  step 7 have no effect. The published page silently lacks the
  documentation section and the navbar "Documentation" entry.

Step 6's framing is understandable (the docs section has no HTML file to
create because the generator wraps README content itself, per
`templates/index.njk`: `<section id="{{ section.id }}" class="docs">`),
but the list is titled "Standard sections in order", which reads as the
complete page structure.

**Grounding**: All quotes above from the skill files themselves;
generator behavior from `generator/bin/generate.ts` (`buildSections`)
and `templates/index.njk` in `jakobwesthoff/project-page-starter`
(local clone at origin HEAD, commit e9be969).

**Proposed change**: In SKILL.md step 6, insert the docs section into
the ordered list between quick-start and footer with a note that it has
no HTML file (config-only entry with `source: readme`; the generator
wraps the extracted README content itself), keeping the list consistent
with config.md's standard order and making step 7's markers purposeful.
