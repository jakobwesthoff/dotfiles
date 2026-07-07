---
name: setup-project-page
description: >-
  Set up docs/pages/ directory and files to generate a project landing page with
  project-page-starter. Use when adding a landing page to a project.
---

# Setup Project Page

This skill scaffolds a landing page using the [project-page-starter](https://github.com/jakobwesthoff/project-page-starter) generator. It creates a complete `docs/pages/` directory structure, configuration, theme, HTML sections, README markers, and optionally a GitHub Actions workflow. The generator repository at <https://github.com/jakobwesthoff/project-page-starter> is the single source of truth for templates, CSS, and the build pipeline.

Local verification (step 9) requires Bun and a local clone of `project-page-starter`, since the generator's `bin/generate.ts` runs under Bun (`#!/usr/bin/env bun`, using `Bun.file`/`Bun.write`).

## Execution Sequence

### 1. Analyze the target project

Inspect the project to extract:

- **Project name** — from README h1, package manifest `name` field, or directory name
- **Tagline** — first paragraph of README or `description` in manifest
- **GitHub path** — `user/repo` from git remote (`git remote get-url origin`) or manifest `repository` field
- **Default branch** — via `git symbolic-ref refs/remotes/origin/HEAD` or equivalent
- **Author** — from package manifest (`author`, `authors`), git config, or README
- **Install methods** — detect from existing docs: npm/yarn/pnpm, cargo, brew, binary releases, pip, go install, etc.
- **3 key features** — strongest value props from README for the highlights section
- **Brand color** — suggest a hex color based on project identity or existing branding; default to `#7c3aed` if nothing fits

### 2. Confirm with user

Present the extracted information and ask the user to confirm or adjust:
- Project name, tagline, GitHub path, author (name + website)
- The 3 highlight features (title + short description each)
- Brand color (hex)
- Whether to create a GitHub Actions workflow for Pages deployment

### 3. Create directory structure

```
docs/pages/
docs/pages/sections/
```

Only create `docs/pages/assets/` when the project actually has assets to add (demo videos, logos). Git does not track empty directories, so an unconditionally created `assets/` vanishes at commit time for projects without assets. If the directory is created ahead of populating it, add a `.gitkeep` placeholder — the generator's `copyAssets()` explicitly skips `.gitkeep` files when copying, so it never reaches the published site.

### 4. Create `docs/pages/config.yaml`

See [references/config.md](references/config.md) for schema, fields, and examples.

### 5. Create `docs/pages/theme.css`

See [references/theme-and-readme.md](references/theme-and-readme.md) for CSS variable overrides.

### 6. Create HTML section files

Create each file in `docs/pages/sections/`. See [references/sections.md](references/sections.md) for complete templates and CSS class reference.

Standard sections in order:
1. `sections/hero.html` — project name, tagline, CTA buttons
2. `sections/highlights.html` — 3-card feature grid
3. `sections/demo.html` — (optional) macOS window frame with video
4. `sections/quick-start.html` — tabbed install instructions
5. `docs` — config-only entry with `source: readme`, no HTML file; the generator wraps the README content extracted in step 7 itself
6. `sections/footer.html` — tagline, credit, optional imprint link

### 7. Add README.md markers

See [references/theme-and-readme.md](references/theme-and-readme.md) for marker format and placement strategy.

### 8. Create GitHub Actions workflow (if requested)

See [references/workflow.md](references/workflow.md) for the complete workflow file.

### 9. Verify the result

If Bun and a local clone of `project-page-starter` are available, run the generator against the scaffolded files:

```bash
bun run <starter>/generator/bin/generate.ts \
  --docs docs/pages --readme README.md \
  --output <scratch-dir>/dist --templates <starter>/templates
```

Confirm it completes without errors, then offer to open `<scratch-dir>/dist/index.html` for review. If Bun or the clone is unavailable, state explicitly that the scaffold has not been built locally and the first validation will happen in CI on the next push.

## Key Analysis Guidance

When analyzing a project, look for these signals:

- **README h1** is almost always the project name
- **First paragraph** after the h1 is usually the best tagline source
- **git remote** is the most reliable GitHub path source; fall back to package manifest
- **Package manifest** varies by ecosystem: `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`
- **Install methods** — check if the project publishes to npm, crates.io, PyPI, Homebrew, or GitHub Releases
- **Features** — look for a "Features" section in README, or infer from the description and usage examples

## Anti-Patterns

- NEVER use CSS functions (like `rgba()`, `var()`) for `--color-primary` or `--color-primary-hover` — they MUST be plain hex values (e.g. `#7c3aed`). The generator injects these values verbatim as SVG fill colors for the auto-generated favicon; a `var()` reference breaks it because the standalone SVG cannot resolve custom properties. Always override both together — each falls back to the base theme independently, so overriding only one produces a two-tone favicon.
- NEVER add `<html>`, `<head>`, `<body>`, or `<!DOCTYPE>` to section files — they are HTML fragments injected into the generator's page template.
- MUST NOT duplicate README content into section files — use `source: readme` in config.yaml to pull documentation from the README.
- NEVER create a section HTML file without a matching entry in the `config.yaml` sections array, and vice versa.
- NEVER use `class="section"` on hero, highlights, quickstart, demo, or footer elements — each has its own layout class that provides the correct spacing.
