---
name: workflow-reference
description: GitHub Actions workflow for automatic GitHub Pages deployment
tags: [github-actions, deployment, pages]
---

# Workflow Reference

GitHub Actions workflow that builds and deploys a landing page using the [project-page-starter](https://github.com/jakobwesthoff/project-page-starter) generator. The canonical workflow source is `workflow/generate-pages.yml` in that repository.

## File Path

`.github/workflows/pages.yml`

## Complete Workflow

```yaml
# GitHub Actions workflow for generating project pages
# Copy this file to your project at .github/workflows/pages.yml

name: Deploy Pages

on:
  push:
    branches: [main]
    paths:
      - 'README.md'
      - 'docs/pages/**'
  workflow_dispatch:  # Allow manual trigger

permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment
concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # Checkout your project
      - uses: actions/checkout@v4
        with:
          path: project

      # Checkout the generator
      - uses: actions/checkout@v4
        with:
          repository: jakobwesthoff/project-page-starter
          path: generator

      # Setup Bun
      - uses: oven-sh/setup-bun@v1

      # Install generator dependencies
      - name: Install dependencies
        run: cd generator/generator && bun install

      # Create output directories
      - name: Create output directories
        run: mkdir -p dist/styles dist/assets

      # Generate the pages
      - name: Generate pages
        run: |
          bun run generator/generator/bin/generate.ts \
            --docs project/docs/pages \
            --readme project/README.md \
            --output dist \
            --templates generator/templates

      # Setup GitHub Pages
      - name: Setup Pages
        uses: actions/configure-pages@v4

      # Upload artifact
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: dist

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## Post-Setup

After adding the workflow file, enable GitHub Pages in the repository:

1. Go to **Settings > Pages**
2. Under "Build and deployment", select **GitHub Actions** as the source

The workflow triggers on pushes to `main` that modify `README.md` or anything in `docs/pages/`. It can also be triggered manually via `workflow_dispatch`.

## How It Works

1. Checks out the target project into `project/`
2. Checks out `jakobwesthoff/project-page-starter` into `generator/`
3. Installs Bun and generator dependencies
4. Runs the generator: reads `project/docs/pages/` config + sections + `project/README.md`, outputs to `dist/` (including copying assets)
5. Uploads `dist/` as a GitHub Pages artifact and deploys

## Anti-Patterns

- NEVER modify the generator checkout path — it MUST be `generator` (the install and generate steps depend on this path)
- MUST NOT change the repository reference from `jakobwesthoff/project-page-starter`
- NEVER change the project checkout path from `project` — all subsequent steps reference this path
