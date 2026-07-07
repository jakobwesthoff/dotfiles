# Theme and README Reference

Theme customization and README marker format for the [project-page-starter](https://github.com/jakobwesthoff/project-page-starter) generator. Default theme variables are defined in `templates/styles/theme.css` in that repository.

## Minimal theme.css

Most projects only need to set the brand colors:

```css
:root {
  --color-primary: #7c3aed;
  --color-primary-hover: #6d28d9;
}
```

The generator merges this with the base theme — you only override what you want to change.

## Extended theme.css Example

For projects that want more control (e.g. an amber brand color with custom h1 gradient):

```css
:root {
  --color-primary: #f59e0b;
  --color-primary-hover: #d97706;
  --color-primary-rgb: 245, 158, 11;
  --color-primary-subtle: rgba(var(--color-primary-rgb), 0.1);
}

/* Custom h1 gradient for short title */
.hero h1 {
  background: linear-gradient(135deg, #fef08a 0%, #f59e0b 40%, #c2410c 100%);
}
```

**Important:** `--color-primary` and `--color-primary-hover` must be plain hex values; see Favicon Hex Constraint below. `--color-primary-subtle` and other non-favicon variables can use CSS functions.

## Favicon Hex Constraint

The generator auto-generates an SVG favicon from `--color-primary` and `--color-primary-hover`. It regex-extracts the raw text after each declaration in theme.css and injects it verbatim as the `fill` value in the favicon SVG template, with no CSS evaluation. A `var(--some-name)` reference breaks the favicon because the standalone SVG has no such custom property to resolve. The house rule stays plain hex values only, so the failure mode is predictable and other CSS color functions are never attempted.

**Valid:**
```css
--color-primary: #f59e0b;
--color-primary-hover: #d97706;
```

**FORBIDDEN:**
```css
--color-primary: rgb(245, 158, 11);       /* not a plain hex value */
--color-primary-hover: var(--some-color);  /* breaks favicon: no such property in the SVG */
```

**Override both together.** `--color-primary` and `--color-primary-hover` each fall back to the base theme's value independently. A theme.css that overrides only one produces a favicon mixing the brand color with the default purple from the other (`#7c3aed` / `#6d28d9`), with no error. Always set both in the same override.

## Full Variable Reference

All variables with their defaults from `templates/styles/theme.css`:

### Brand Colors
| Variable | Default | Purpose |
|----------|---------|---------|
| `--color-primary` | `#7c3aed` | Main accent: buttons, links, favicon |
| `--color-primary-hover` | `#6d28d9` | Hover state for primary, favicon |
| `--color-primary-subtle` | `#2d2640` | Subtle accent for borders/backgrounds |

### Warning Colors
| Variable | Default | Purpose |
|----------|---------|---------|
| `--color-warning-rgb` | `245, 158, 11` | RGB components for the warning palette |
| `--color-warning` | `rgb(var(--color-warning-rgb))` | `.callout-warning` accent (WARNING/CAUTION alerts) |
| `--color-warning-subtle` | `rgba(var(--color-warning-rgb), 0.1)` | `.callout-warning` background tint |

### Backgrounds
| Variable | Default | Purpose |
|----------|---------|---------|
| `--color-bg` | `#0f0f14` | Page background |
| `--color-bg-transparent` | `rgba(15, 15, 20, 0.9)` | Semi-transparent navbar |
| `--color-bg-alt` | `#1a1a24` | Alternate section backgrounds |
| `--color-bg-card` | `#1f1f2e` | Card backgrounds |
| `--color-bg-code` | `#1e1e2e` | Code block backgrounds |
| `--color-bg-titlebar` | `#1a1a20` | macOS window titlebar |

Code token *foreground* colors are generated at build time by Shiki using the hardcoded `github-dark` theme and land as inline `style` colors on each span; they do not read theme variables. `--color-bg-code` changes only the background behind the tokens, so a light-background override leaves code blocks styled with a dark-background token palette.

### Text
| Variable | Default | Purpose |
|----------|---------|---------|
| `--color-text` | `#e5e5e5` | Body text |
| `--color-text-muted` | `#9ca3af` | Secondary text |
| `--color-text-bright` | `#ffffff` | Headings, emphasis |

### Borders & Shadows
| Variable | Default | Purpose |
|----------|---------|---------|
| `--color-border` | `#2e2e3e` | Card borders, dividers |
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.3)` | Subtle shadow |
| `--shadow-md` | `0 4px 12px rgba(0,0,0,0.4)` | Medium shadow |
| `--shadow-lg` | `0 20px 50px rgba(0,0,0,0.5)` | Large shadow |

### Typography
| Variable | Default | Purpose |
|----------|---------|---------|
| `--font-sans` | `system-ui, -apple-system, ...sans-serif` | Body font |
| `--font-mono` | `Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace` | Code font |

### Spacing
| Variable | Default | Purpose |
|----------|---------|---------|
| `--space-xs` | `0.25rem` | 4px |
| `--space-sm` | `0.5rem` | 8px |
| `--space-md` | `1rem` | 16px |
| `--space-lg` | `2rem` | 32px |
| `--space-xl` | `4rem` | 64px |
| `--space-2xl` | `6rem` | 96px |

### Layout
| Variable | Default | Purpose |
|----------|---------|---------|
| `--container-max` | `900px` | Max content width |
| `--border-radius` | `8px` | Standard border radius |
| `--border-radius-lg` | `12px` | Large border radius |
| `--transition-fast` | `150ms ease` | Fast transitions |
| `--transition-normal` | `250ms ease` | Normal transitions |

## README Markers

The generator extracts content between these exact marker strings:

```markdown
<!-- docs:start -->
## Documentation

Your documentation content here. Supports full Markdown:
headings, tables, code blocks with syntax highlighting, lists, etc.

<!-- docs:end -->
```

### Rules

- Markers MUST be on their own lines. Extraction is character-offset based (the generator finds the marker strings with `indexOf` and slices the text between them), so a violation does not error — same-line text next to a marker silently leaks into or out of the extracted region instead.
- Only content **between** the markers is extracted
- The rest of the README is ignored by the generator
- Markdown is rendered to HTML with syntax-highlighted code blocks at build time
- The corresponding section in config.yaml uses `source: readme` (not `file`)

### What the Renderer Supports

- **GitHub-style alerts become styled callouts.** A blockquote starting with `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, or `[!CAUTION]` renders as a `.callout-box` div; `[!WARNING]` and `[!CAUTION]` additionally get the `.callout-warning` class.
- **Headings get GitHub-compatible anchor ids**, so in-README anchor links (e.g. `[see config](#configuration)`) keep working on the generated page. Because section ids in config.yaml render as `<section id="{{ section.id }}">` on the same page, a README heading whose slug matches a config section id (e.g. a `## Demo` heading producing `id="demo"` next to a `demo` section) creates a duplicate id; anchor navigation then resolves to whichever element comes first in the document.
- **Tables are wrapped** in `<div class="docs-table"><table class="table">...</table></div>`, which is why README tables pick up the page's table styling.

### Placement Strategy

**Include between markers:**
- Detailed documentation, CLI reference, API docs
- Usage examples with code blocks
- Configuration reference tables
- Real-world example commands

**Exclude from markers** (keep outside):
- Badges / shields at the top of the README
- Basic install instructions (these go in the quickstart section instead)
- Contributing guidelines
- License section
- The project title and opening paragraph (these become the hero)

### Example README Structure

```markdown
# My Project

Short description here.

## Installation

Install instructions here (NOT inside markers — this goes in quick-start.html)

<!-- docs:start -->
## Documentation

Detailed docs, CLI reference, examples, etc.

### Subheading

More detailed content...

<!-- docs:end -->

## Contributing

Guidelines here (NOT inside markers)

## License

MIT (NOT inside markers)
```

## Anti-Patterns

- NEVER use CSS functions for `--color-primary` or `--color-primary-hover` — see Favicon Hex Constraint above
- NEVER wrap the entire README in markers — only the documentation section belongs inside
- MUST NOT nest markers or include multiple marker pairs — use exactly one `<!-- docs:start -->` and one `<!-- docs:end -->`
- MUST NOT forget to add markers when using `source: readme` in config.yaml — the generator will error
