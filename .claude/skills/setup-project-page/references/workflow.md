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
      - uses: actions/checkout@v6
        with:
          path: project

      # Checkout the generator
      - uses: actions/checkout@v6
        with:
          repository: jakobwesthoff/project-page-starter
          path: generator

      # Setup Bun
      - uses: oven-sh/setup-bun@v2

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
        uses: actions/configure-pages@v6

      # Upload artifact
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v5
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
        uses: actions/deploy-pages@v5
```

Replace `main` in `branches: [main]` with the target repository's default branch if it differs.

## Post-Setup

Enable GitHub Pages in the repository **before** pushing the scaffold:

1. Go to **Settings > Pages**
2. Under "Build and deployment", select **GitHub Actions** as the source

The workflow triggers on pushes to `main` that modify `README.md` or anything in `docs/pages/`, so the very push that adds `docs/pages/` triggers the first run. It can also be triggered manually via `workflow_dispatch`.

If Pages is not yet enabled when the first run reaches the `Setup Pages` step, `actions/configure-pages` fails with "Get Pages site failed. Please verify that the repository has Pages enabled and configured to build using GitHub Actions...". Recover by enabling Pages as above, then re-run the failed workflow from the Actions tab or trigger it again via `workflow_dispatch`. `configure-pages`'s `enablement` input can auto-enable Pages, but it requires a PAT or App token with `repo`/Pages write permission instead of the default `GITHUB_TOKEN`, so this workflow does not use it.

A custom domain is configured entirely in **Settings > Pages > Custom domain** plus DNS records; no file in the generated artifact needs to change. A `CNAME` file in the artifact is ignored for Actions-based deploys, so don't add one.

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
