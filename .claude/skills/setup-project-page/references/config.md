---
name: config-reference
description: Schema and examples for docs/pages/config.yaml
tags: [config, yaml, sections, navbar]
---

# Config Reference

Configuration schema for the [project-page-starter](https://github.com/jakobwesthoff/project-page-starter) generator. Types are defined in `generator/lib/config.ts` in that repository.

## TypeScript Types

These are the exact types from `generator/lib/config.ts`:

```typescript
type Section = {
  id: string;
  file?: string;
  source?: "readme";
  nav: boolean;
  nav_label?: string;
};

type NavbarButton = {
  label: string;
  href: string;
  style?: "primary" | "secondary";
  icon?: "github" | "download";
};

type Imprint = {
  enabled: boolean;
  name: string;
  address: string;
  email_encrypted: string;
  phone_encrypted: string;
  encryption_key: string;
};

type Config = {
  name: string;
  tagline: string;
  github: string;
  author: {
    name: string;
    website: string;
  };
  sections: Section[];
  navbar_buttons?: NavbarButton[];
  imprint?: Imprint;
};
```

## Complete config.yaml Example

```yaml
name: my-project
tagline: A short description of what the project does
github: username/my-project

author:
  name: Your Name
  website: https://yoursite.com

navbar_buttons:
  - label: Quick Start
    href: "#quickstart"
    style: primary
    icon: download
  - label: GitHub
    href: https://github.com/username/my-project
    style: secondary
    icon: github

sections:
  - id: hero
    file: sections/hero.html
    nav: false

  - id: highlights
    file: sections/highlights.html
    nav: false

  - id: demo
    file: sections/demo.html
    nav: true
    nav_label: Demo

  - id: quickstart
    file: sections/quick-start.html
    nav: true
    nav_label: Quick Start

  - id: docs
    source: readme
    nav: true
    nav_label: Documentation

  - id: footer
    file: sections/footer.html
    nav: false
```

## Required Fields

| Field | Validated | Description |
|-------|-----------|-------------|
| `name` | Yes | Project name — shown in navbar and page title |
| `github` | Yes | GitHub path as `username/repo` |
| `sections` | Yes | Non-empty array of section definitions |
| `tagline` | No* | Short description — used in page title and templates |
| `author` | No* | Object with `name` and `website` — used in footer templates |

\*Not validated by the generator but expected by the built-in templates. Always include them.

## Sections Array Rules

- Each section MUST have either `file` or `source`, NEVER both
- `source: readme` is the **only** supported source value
- `file` paths are relative to the `docs/pages/` directory (e.g. `sections/hero.html`)
- If `nav: true`, then `nav_label` is required (the text shown in the navbar)
- If `nav: false`, `nav_label` is ignored
- The `id` is used as the `#anchor` in the URL and must be unique
- Standard section order: hero, highlights, demo (optional), quickstart, docs, footer
- Omit the demo section entirely if the project has no demo video

## Navbar Buttons

**Default behavior:** When `navbar_buttons` is omitted, the navbar shows a single GitHub button linking to `https://github.com/{config.github}`.

**Custom buttons:** Provide an array to override. Typical pattern is a primary CTA + secondary GitHub link:

```yaml
navbar_buttons:
  - label: Quick Start
    href: "#quickstart"
    style: primary
    icon: download
  - label: GitHub
    href: https://github.com/username/repo
    style: secondary
    icon: github
```

| Property | Required | Values |
|----------|----------|--------|
| `label` | Yes | Button text |
| `href` | Yes | URL or `#anchor` |
| `style` | No | `primary` (filled) or `secondary` (outline, default) |
| `icon` | No | `github` or `download` |

## Imprint (Optional)

For German legal compliance (§ 5 TMG). When enabled, the generator produces an `imprint.html` page. Contact details are encrypted to prevent scraping.

```yaml
imprint:
  enabled: true
  name: Full Name
  address: |
    Street 123
    12345 City
    Country
  email_encrypted: "encrypted-string"
  phone_encrypted: "encrypted-string"
  encryption_key: "your-key"
```

Most projects outside Germany should omit this entirely.

## Anti-Patterns

- NEVER set `nav: true` without providing `nav_label` — the navbar link will have no text
- NEVER specify both `file` and `source` on the same section — use one or the other
- MUST NOT leave the `sections` array empty — the generator will throw an error
- NEVER use `source: readme` without adding `<!-- docs:start -->` / `<!-- docs:end -->` markers to the README
