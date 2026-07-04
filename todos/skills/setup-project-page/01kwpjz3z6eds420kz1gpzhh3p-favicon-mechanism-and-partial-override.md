# Favicon constraint: mechanism described inaccurately; partial-override pitfall undocumented

**Skill**: setup-project-page
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/setup-project-page/SKILL.md` — "Anti-Patterns" bullet 1
- `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/theme-and-readme.md` — "Favicon Hex Constraint" section

**Current state**: Both files say `--color-primary` and
`--color-primary-hover` "are parsed as hex" / "These values are parsed
as hex strings — not evaluated as CSS. If they contain `rgba()`,
`var()`, or any CSS function, the favicon will break."

**Problems**:

1. **Mechanism misdescribed.** Nothing parses or validates hex. The
   generator regex-extracts whatever literal appears after the colon and
   injects it verbatim into an SVG `style="fill:..."` attribute. The
   consequence differs by value: `var(--x)` genuinely breaks (the SVG
   has no such custom property), while `rgb()`/`rgba()` are valid CSS
   fill values inside an SVG. The hex-only rule is still the right
   conservative instruction, but the stated rationale is wrong, and an
   agent reasoning from a wrong mechanism may draw wrong conclusions
   (e.g. "named colors also break" — they would actually work).
2. **Partial-override pitfall missing.** The two colors are resolved
   independently with per-color fallback to the base theme. A project
   theme.css that overrides only `--color-primary` produces a favicon
   mixing the brand color with the default purple hover (`#6d28d9`),
   with no error. The skill never says the two must be overridden
   together.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `generator/lib/theme.ts` `extractThemeColors()`: regexes
  `--color-primary:\s*([^;]+);` and `--color-primary-hover:\s*([^;]+);`,
  returns the raw trimmed match, no hex validation.
- `templates/favicon.svg.njk` lines 5 and 8: values land verbatim in
  `style="fill:{{ primaryColor }};"` and
  `style="fill:{{ primaryHoverColor }};"`.
- `generator/bin/generate.ts` `buildTheme()` lines 118-120:
  `primaryColor = projectColors?.primary ?? baseColors.primary` and the
  same pattern for hover, i.e. independent per-color fallback to the base
  theme (`#7c3aed` / `#6d28d9` per `templates/styles/theme.css`).

**Proposed change**:

1. Reword the mechanism in theme-and-readme.md: values are extracted
   textually from theme.css and injected verbatim as SVG fill colors;
   `var()` references break because they cannot resolve inside the
   standalone favicon; keep the "plain hex only" rule as the house
   constraint.
2. Add: "Always override `--color-primary` and `--color-primary-hover`
   together — each falls back to the base theme independently, so
   overriding only one silently produces a two-tone favicon mixing your
   brand color with the default purple."
