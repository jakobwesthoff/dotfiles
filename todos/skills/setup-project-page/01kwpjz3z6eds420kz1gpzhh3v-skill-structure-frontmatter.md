# Skill structure: inert reference-file frontmatter, rule duplication, and activation tuning

**Skill**: setup-project-page
**Files**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/SKILL.md` and all four files under `references/`

Three structural observations, measured against the official Claude Code
skills documentation (https://code.claude.com/docs/en/skills, fetched
2026-07-04) and the anthropics/skills repository README:

## 1. Reference files carry frontmatter that nothing consumes

Each reference file starts with YAML frontmatter (`name`, `description`,
`tags`), e.g. config.md:

```yaml
name: config-reference
description: Schema and examples for docs/pages/config.yaml
tags: [config, yaml, sections, navbar]
```

Per the docs, YAML frontmatter configures `SKILL.md`; supporting files
are shown as plain markdown in the documentation's example layout
(`reference.md (detailed API docs - loaded when needed)`), and `tags` is
not a field in the frontmatter reference at all (documented fields
include `name`, `description`, `when_to_use`, `allowed-tools`,
`disallowed-tools`, `context`, `agent`, `arguments`,
`disable-model-invocation`, `user-invocable`). The reference-file
frontmatter is inert: these files are only ever loaded via Read when
SKILL.md links to them. Harmless, but it implies a discovery mechanism
that does not exist. Proposed: drop the frontmatter blocks from the four
reference files (keep the `# Title` heading).

## 2. The same rules are stated in multiple places

- The favicon hex rule appears four times: SKILL.md Anti-Patterns
  bullet 1, and three times inside theme-and-readme.md (the "Important:"
  note after the extended example, the "Favicon Hex Constraint" section,
  and Anti-Patterns bullet 1).
- The HTML-fragment rule (no `<html>/<head>/<body>/<!DOCTYPE>`) appears
  in SKILL.md Anti-Patterns, sections.md General Rules, and sections.md
  Anti-Patterns.
- The `class="section"` ban appears in SKILL.md Anti-Patterns,
  sections.md General Rules, and sections.md Anti-Patterns.

Multiple statements of one rule must all be updated together when the
generator changes; a single authoritative statement per rule (with
SKILL.md keeping only the pointer, per the docs' progressive-disclosure
guidance to keep SKILL.md focused and move detail into supporting files)
removes that maintenance surface. Proposed: state each rule once in the
relevant reference file; keep SKILL.md's Anti-Patterns list as
one-liners only if they add pre-dispatch value, otherwise link.

## 3. Activation/description tuning

Current description: "Set up docs/pages/ directory and files to generate
a project landing page with project-page-starter. Use when adding a
landing page to a project." This does follow the documented "what the
skill does and when to use it" pattern. The docs additionally provide a
`when_to_use` frontmatter field: "Additional context for when Claude
should invoke the skill, such as trigger phrases or example requests.
Appended to `description` in the skill listing" (combined cap 1,536
characters). Proposed: add a `when_to_use` line with realistic trigger
phrases ("project page", "landing page", "GitHub Pages site for this
repo", "docs/pages") to improve automatic activation.

**Also verified, no action needed**: SKILL.md body is 87 lines, well
under the documented "Keep SKILL.md under 500 lines" tip; SKILL.md
links each reference file with a note on what it contains, matching the
docs' supporting-files guidance; the directory name matches the
frontmatter `name`.
