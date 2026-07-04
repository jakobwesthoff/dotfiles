# config.md misstates how `tagline` and `author` are consumed

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/config.md` — "Required Fields" table and footnote

**Current state**: The table says `tagline` is "used in page title and
templates" and `author` is an "Object with `name` and `website` — used
in footer templates", with the footnote "Not validated by the generator
but expected by the built-in templates. Always include them."

**Problem**: For `author` this is false. No built-in template references
`config.author` at all. The footer is a user-authored static HTML
fragment (the skill's own footer template hardcodes the author name and
website as literal text), and the imprint page uses
`config.imprint.name`, not `author`. Omitting `author` today changes
nothing in the generated output. An agent told the field is "expected by
the built-in templates" cannot explain to a user what it actually does.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `grep -rn 'config.author' templates/` returns nothing;
  `config.tagline` appears exactly twice, both in `templates/base.njk`:
  `<title>{{ config.name }} - {{ config.tagline }}</title>` and
  `<meta name="description" content="{{ config.tagline }}">`.
- `templates/imprint.njk` uses `config.imprint.name` for the legal
  contact block.
- The skill's own `footer.html` template in sections.md hardcodes
  `Made with <span class="footer-heart">&hearts;</span> by
  <a href="https://yoursite.com">Your Name</a>` — no config reference
  (sections are static fragments; the generator performs no substitution
  in them, per `generator/bin/generate.ts` `buildSections()`, which only
  runs syntax highlighting over file-based sections).

**Proposed change**: Correct the table: `tagline` is used in the page
`<title>` and the `<meta name="description">`; `author` is not consumed
by any built-in template — it serves as the source of truth the agent
uses when writing the footer section's hardcoded credit line (and may be
consumed by future templates). Adjust the footnote accordingly so it no
longer claims template usage for `author`.
