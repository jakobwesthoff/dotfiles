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
| `tagline` | No* | Short description — used in the page `<title>` and `<meta name="description">` |
| `author` | No** | Object with `name` and `website` |

\*Not validated by the generator but rendered by `base.njk`. Always include it.

\*\*Not consumed by any built-in template. It is the source of truth an agent uses when writing the footer section's static credit line (`sections.md`'s `footer.html` hardcodes the name and website as literal text; the generator performs no substitution in section files).

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

For German legal compliance (§ 5 TMG). When enabled, the generator produces an `imprint.html` page. Contact details are encrypted to prevent scraping: `email_encrypted` and `phone_encrypted` hold the email and phone, each XOR'd byte-by-byte with a ROT13'd version of `encryption_key` and base64-encoded. `encryption_key` itself is stored **plain** (not ROT13'd) in `config.yaml`; `imprint.njk` applies ROT13 to it client-side before decrypting. A `<noscript>` fallback tells visitors JavaScript is required to see the contact info.

Generate the encrypted values with this Node.js snippet before filling in the config:

```javascript
function rot13(str) {
  return str.replace(/[a-zA-Z]/g, char => {
    const code = char.charCodeAt(0);
    const base = code >= 65 && code <= 90 ? 65 : 97;
    return String.fromCharCode((code - base + 13) % 26 + base);
  });
}

function encrypt(text, key) {
  const rot13Key = rot13(key);
  let result = '';
  for (let i = 0; i < text.length; i++) {
    result += String.fromCharCode(text.charCodeAt(i) ^ rot13Key.charCodeAt(i % rot13Key.length));
  }
  return btoa(result);
}

const key = 'your-secret-key';
console.log('email:', encrypt('your@email.com', key));
console.log('phone:', encrypt('+49 123 456789', key));
```

```yaml
imprint:
  enabled: true
  name: Full Name
  address: |
    Street 123
    12345 City
    Country
  email_encrypted: "output-from-script"
  phone_encrypted: "output-from-script"
  encryption_key: "your-secret-key"
```

Most projects outside Germany should omit this entirely.

## Anti-Patterns

- NEVER set `nav: true` without providing `nav_label` — the navbar link will have no text
- NEVER specify both `file` and `source` on the same section — use one or the other. `buildSections()` checks `source === "readme"` first, so when both are present the generator silently uses `source` and ignores `file`
- Do not leave a section with neither `file` nor `source`. The generator does not error; it logs `<id>: skipped (no source)` and omits the section from the page
- MUST NOT leave the `sections` array empty — the generator will throw an error
- NEVER use `source: readme` without adding `<!-- docs:start -->` / `<!-- docs:end -->` markers to the README
