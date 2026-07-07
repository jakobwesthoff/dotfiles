# Sections Reference

HTML section templates and CSS classes for the [project-page-starter](https://github.com/jakobwesthoff/project-page-starter) generator. The canonical CSS definitions live in `templates/styles/layout.css` and `templates/styles/components.css` in that repository.

## General Rules

- Section files are **HTML fragments only** — no `<html>`, `<head>`, `<body>`, or `<!DOCTYPE>`
- The outermost element needs an `id` only when the section is linked to: every section with `nav: true` in config.yaml, plus any section targeted by an in-page link (e.g. the hero's `#quickstart` CTA). Sections with `nav: false` and no inbound link (hero, highlights, footer in the standard layout) do not need an id. `source: readme` sections get their id from the generator automatically.
- Each section type has its own CSS class that provides spacing — do NOT add `class="section"` alongside these
- Wrap content in `.container` for centered, max-width layout
- Inside `<code>` elements, escape `<` as `&lt;` and `&` as `&amp;`: section HTML is parsed with a real HTML parser before syntax highlighting, and unescaped angle-bracket content (CLI placeholders like `<file>`, generics like `Vec<String>`) is read as markup and silently dropped from the highlighted output

## hero.html

The first thing visitors see. Project name, tagline, and call-to-action buttons.

```html
<section class="hero">
  <div class="container">
    <h1>Project Name</h1>
    <p class="hero-tagline">
      A short, catchy description of what the project does.
    </p>
    <div class="hero-actions">
      <a href="#quickstart" class="btn btn-primary btn-lg">
        <i data-icon="download"></i>
        Quick Start
      </a>
      <a href="https://github.com/user/repo" class="btn btn-secondary btn-lg">
        <i data-icon="github"></i>
        View on GitHub
      </a>
    </div>
  </div>
</section>
```

**Key classes:**
- `.hero` — provides top padding (accounts for fixed navbar) and bottom spacing
- `.hero-tagline` — muted, centered description text below h1
- `.hero-actions` — flex container for CTA buttons, centered with gap
- `.hero-subtitle` + `.hero-subtitle-highlight` — optional subtitle above tagline (for acronym-style names)
- `.hero-logo` + `.hero-logo-img` — optional logo image above h1

**Icons:** The available set is exhaustive: only `<i data-icon="download"></i>` and `<i data-icon="github"></i>` are replaced at build time with inline SVGs. An unknown name produces no build error, only a build-log warning, and leaves an empty spot on the page.

**Button sizes:** Use `.btn-lg` for hero buttons to make them prominent.

## highlights.html

Three feature cards in a grid. Communicates key value props at a glance. Always exactly 3 cards.

```html
<section class="highlights">
  <div class="container">
    <div class="highlights-grid">
      <div class="highlight">
        <h3>Feature One</h3>
        <p>Short description of the first key feature or value proposition.</p>
      </div>
      <div class="highlight">
        <h3>Feature Two</h3>
        <p>Short description of the second key feature or value proposition.</p>
      </div>
      <div class="highlight">
        <h3>Feature Three</h3>
        <p>Short description of the third key feature or value proposition.</p>
      </div>
    </div>
  </div>
</section>
```

**Key classes:**
- `.highlights` — section spacing (tight top padding, larger bottom)
- `.highlights-grid` — 3-column CSS grid, collapses to 1 column on mobile
- `.highlight` — centered text card with hover background effect

**No section title.** Highlights sit directly below the hero without a heading.

## demo.html (Optional)

A demo video wrapped in a macOS-style terminal frame. Skip this section entirely if no demo video exists — just remove it from config.yaml.

```html
<section id="demo" class="demo">
  <div class="container">
    <div class="macos-window">
      <div class="macos-window-titlebar">
        <div class="macos-window-buttons">
          <span class="macos-window-button close"></span>
          <span class="macos-window-button minimize"></span>
          <span class="macos-window-button maximize"></span>
        </div>
        <span class="macos-window-title">Terminal</span>
      </div>
      <div class="macos-window-content">
        <video autoplay loop muted playsinline>
          <source src="assets/demo.webm" type="video/webm">
          <source src="assets/demo.mp4" type="video/mp4">
        </video>
      </div>
    </div>
  </div>
</section>
```

**Key classes:**
- `.demo` — section with alternate background color
- `.macos-window` — rounded container with shadow
- `.macos-window-titlebar` — gradient titlebar with flex layout
- `.macos-window-buttons` — flex container for the 3 dots
- `.macos-window-button.close` / `.minimize` / `.maximize` — colored circles
- `.macos-window-title` — centered title text in titlebar
- `.macos-window-content` — content area (video fills width)

**Without the frame:** For GUI apps or screencasts where a fake terminal frame is wrong, drop the `.macos-window` wrapper and put the `.demo-video` class directly on the `<video>` element:

```html
<section id="demo" class="demo">
  <div class="container">
    <video autoplay loop muted playsinline class="demo-video">
      <source src="assets/demo.webm" type="video/webm">
      <source src="assets/demo.mp4" type="video/mp4">
    </video>
  </div>
</section>
```

**Video sources:** Always provide both `.webm` (primary) and `.mp4` (fallback for older Safari: iOS before 17.4, macOS Safari before 14.1/Big Sur). Videos go in `docs/pages/assets/`.

**Producing the video:** For CLI projects, the starter repo's `vhs/` directory ships a pre-configured `vhs/demo.tape` with a theme matching the landing page colors. Recording is `cd vhs && vhs demo.tape`, then copying the resulting `demo.webm`/`demo.mp4` into `docs/pages/assets/`. The tape records at 2x resolution (e.g. 1800x800 for a 900x400 display size) so the video stays crisp on HiDPI screens. Requirements: `vhs`, `ttyd`, and `ffmpeg` (all brew-installable).

## quick-start.html

Installation instructions with tabbed variants. Adapt the tabs to match the project's actual install methods.

```html
<section id="quickstart" class="quickstart">
  <div class="container">
    <h2>Quick Start</h2>

    <div class="tabs">
      <div class="tab-buttons">
        <button class="tab-button active" data-tab="npm">npm</button>
        <button class="tab-button" data-tab="yarn">yarn</button>
        <button class="tab-button" data-tab="source">Source</button>
      </div>
      <div class="tab-panels">
        <div class="tab-panel active" data-tab="npm">
          <div class="code-block">
            <pre><code class="language-bash">npm install my-project</code></pre>
          </div>
        </div>
        <div class="tab-panel" data-tab="yarn">
          <div class="code-block">
            <pre><code class="language-bash">yarn add my-project</code></pre>
          </div>
        </div>
        <div class="tab-panel" data-tab="source">
          <div class="code-block">
            <pre><code class="language-bash">git clone https://github.com/user/repo
cd repo
npm install
npm run build</code></pre>
          </div>
        </div>
      </div>
    </div>

    <h3>Basic Usage</h3>
    <div class="code-block">
      <pre><code class="language-bash">my-project --help</code></pre>
    </div>
  </div>
</section>
```

**Key classes:**
- `.quickstart` — section spacing with centered h2
- `.tabs` — tab container with bottom margin
- `.tab-buttons` — inline-flex container with background pill shape
- `.tab-button` — individual tab; add `.active` to the default tab
- `.tab-button[data-tab]` — the `data-tab` attribute links buttons to panels
- `.tab-panels` — bordered container for panel content
- `.tab-panel` — hidden by default; add `.active` to show the default panel
- `.code-block` > `pre` > `code.language-{lang}` — syntax-highlighted code

**Tab wiring:** Matching `data-tab` attributes on button and panel are wired up automatically by the built-in JavaScript. The first tab MUST have `.active` on both its button and panel.

**Adapt tabs to the project.** Common patterns:
- **Rust:** Cargo / Binary Releases / From Source
- **Node.js:** npm / yarn / pnpm
- **Python:** pip / pipx / From Source
- **Go:** go install / Binary Releases / From Source
- **Homebrew available:** add a Homebrew tab

## footer.html

Page footer with tagline, credit line, and optional imprint link.

```html
<footer class="footer">
  <div class="container">
    <div class="footer-content">
      <p class="footer-tagline">Your project tagline here</p>
      <p class="footer-credit">
        Made with <span class="footer-heart">&hearts;</span> by
        <a href="https://yoursite.com">Your Name</a>
      </p>
    </div>
  </div>
</footer>
```

**With imprint link** (when imprint is enabled in config):

```html
<footer class="footer">
  <div class="container">
    <div class="footer-content">
      <p class="footer-tagline">Your project tagline here</p>
      <p class="footer-credit">
        Made with <span class="footer-heart">&hearts;</span> by
        <a href="https://yoursite.com">Your Name</a> |
        <a href="imprint.html">Imprint/Impressum</a>
      </p>
    </div>
  </div>
</footer>
```

**Key classes:**
- `.footer` — top border, centered text, vertical padding
- `.footer-content` — flex column with small gap
- `.footer-tagline` — muted, small text
- `.footer-credit` — muted, small text with link styling
- `.footer-heart` — colored with primary accent

## CSS Class Quick Reference

### Layout
| Class | Purpose |
|-------|---------|
| `.container` | Centered max-width wrapper |

Alternate backgrounds come from the section classes themselves (`.demo`, `.docs`, `.table th`, `.docs-table`), which set `background-color: var(--color-bg-alt)` directly — there is no standalone `.bg-alt` class.

### Section Types (use instead of `.section`)
| Class | Purpose |
|-------|---------|
| `.hero` | Hero section with navbar offset |
| `.highlights` | Feature highlights grid section |
| `.demo` | Demo section with alt background |
| `.quickstart` | Install/quickstart section |
| `.footer` | Page footer with top border |

### Grid
| Class | Purpose |
|-------|---------|
| `.highlights-grid` | 3-column highlight cards |
| `.grid` | Generic CSS grid |
| `.grid-2` | 2-column grid |
| `.grid-3` | 3-column grid |

### Typography
| Class | Purpose |
|-------|---------|
| `.text-center` | Center-aligned text |
| `.text-left` | Left-aligned text |
| `.text-right` | Right-aligned text |
| `.text-muted` | Muted/secondary color |
| `.text-bright` | Brighter text color |
| `.text-primary` | Primary accent color |
| `.text-sm` | Smaller text |
| `.text-lg` | Larger text |
| `.text-xl` | Largest text |

### Buttons
| Class | Purpose |
|-------|---------|
| `.btn` | Base button |
| `.btn-primary` | Filled primary button |
| `.btn-secondary` | Outline secondary button |
| `.btn-sm` | Small button |
| `.btn-lg` | Large button |

### Components
| Class | Purpose |
|-------|---------|
| `.code-block` | Code block wrapper (accent left border) |
| `.tabs` | Tab container |
| `.tab-buttons` | Tab button row |
| `.tab-button` | Individual tab button |
| `.tab-panels` | Tab content container |
| `.tab-panel` | Individual tab content |
| `.macos-window` | macOS window frame |
| `.macos-window-titlebar` | Window titlebar |
| `.macos-window-buttons` | Titlebar button group |
| `.macos-window-button` | Single titlebar dot (.close/.minimize/.maximize) |
| `.macos-window-title` | Titlebar title text |
| `.macos-window-content` | Window content area |
| `.feature-box` | Card with hover border effect |
| `.callout-box` | Notice/tip box (primary accent) |
| `.callout-warning` | Warning variant of callout |
| `.demo-video` | Standalone demo video, no window frame |
| `.card` | Bordered card with background and shadow |
| `.docs-table` | Bordered wrapper around `.table` (used by README-rendered tables) |
| `.table` | Table styling (borders, header background, cell padding) |
| `.hero-logo-full` | Full logo image above the hero h1 |

### Flex & Visibility Utilities
| Class | Purpose |
|-------|---------|
| `.flex` | `display: flex` |
| `.flex-center` | Flex, centered on both axes |
| `.flex-between` | Flex, space-between with centered cross axis |
| `.gap-sm` / `.gap-md` / `.gap-lg` | Gap between flex/grid children |
| `.hidden` | `display: none` |
| `.visually-hidden` | Visually hidden but accessible to screen readers |
| `.block` | `display: block` |
| `.inline-block` | `display: inline-block` |

### Spacing Utilities
| Pattern | Sizes |
|---------|-------|
| `.mt-{size}` | Margin top: 0, sm, md, lg, xl |
| `.mb-{size}` | Margin bottom: 0, sm, md, lg, xl |
| `.py-{size}` | Padding vertical: sm, md, lg, xl, 2xl |
| `.px-{size}` | Padding horizontal: sm, md, lg |

## Supported Syntax Highlighting Languages

| Language class | Aliases |
|----------------|---------|
| `language-bash` | `language-shell`, `language-sh`, `language-zsh` |
| `language-json` | |
| `language-yaml` | |
| `language-toml` | |
| `language-typescript` | |
| `language-javascript` | |
| `language-rust` | |
| `language-go` | |
| `language-lua` | |

Unrecognized languages render as plain text.

## Anti-Patterns

- NEVER use `.grid-3` / `.feature-box` for highlights — use `.highlights-grid` / `.highlight`
- NEVER use `.hero-buttons` — the correct class is `.hero-actions`
- NEVER use `.macos-btn` — the correct class is `.macos-window-button`
- NEVER use `.macos-titlebar` — the correct class is `.macos-window-titlebar`
- NEVER use `.macos-content` — the correct class is `.macos-window-content`
- NEVER use `.macos-buttons` — the correct class is `.macos-window-buttons`
- MUST NOT use `class="section"` — see General Rules above
- MUST NOT add `<html>`, `<head>`, or `<body>` tags — see General Rules above
- NEVER put raw `<placeholder>` text inside code blocks in section files — escape `<` and `&` or the content is parsed as markup and silently dropped
