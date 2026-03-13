---
name: writing-principles
description: >-
  Practical writing guide for skill content — prescriptive style, code-first
  approach, anti-patterns, and the pre-ship checklist.
metadata:
  tags: writing, style, quality, checklist, best-practices
---

## Core Philosophy

A skill is **not** documentation. It is **opinionated guidance** that tells an AI
what to do, what not to do, and exactly how to do it. Every line should earn its
place by directly improving the AI's output.

## Be Prescriptive, Not Descriptive

Bad — describes the API:
> The `interpolate` function takes an input value, an input range, and an output
> range. It also accepts an optional options object.

Good — tells the AI what to do:
```markdown
A simple linear interpolation is done using the `interpolate` function.

\`\`\`ts
const opacity = interpolate(frame, [0, 100], [0, 1]);
\`\`\`

By default, values are not clamped. Here is how they can be clamped:

\`\`\`ts
const opacity = interpolate(frame, [0, 100], [0, 1], {
  extrapolateRight: 'clamp',
  extrapolateLeft: 'clamp',
});
\`\`\`
```

The AI doesn't need a function signature walkthrough. It needs to see the correct
usage pattern and the most common configuration.

## Code First, Prose Second

Code examples are the primary instruction mechanism. Prose connects and provides
context, but the code IS the rule.

- Show the correct pattern immediately — don't build up to it
- Every code block should be copy-paste ready
- Include imports in examples — the AI shouldn't have to guess them
- Use the project's actual import paths, naming conventions, and patterns

## State Anti-Patterns Explicitly

When there are common mistakes the AI is likely to make, call them out with
strong language:

```markdown
CSS transitions or animations are FORBIDDEN — they will not render correctly.
```

```markdown
NEVER use `setTimeout` or `setInterval`. All timing must come from `useCurrentFrame()`.
```

Don't just show the right way — **explicitly forbid the wrong way**. LLMs are
trained on vast amounts of general-purpose code and will default to common
patterns from other domains unless told otherwise.

Use: `FORBIDDEN`, `NEVER`, `MUST NOT`, `DO NOT`.

## Cross-Reference Related Files

Reference files should form a navigable graph. When topic A relates to topic B,
link between them:

```markdown
For caption display patterns, see [references/display-captions.md](references/display-captions.md).
```

Rules:
- Use relative paths from the skill root
- Keep references **one level deep** — avoid chains where A links to B links to C
- Two patterns: hub-to-spokes (general → specific) and bidirectional (peer ↔ peer)

## Write a Good Description

The `description` field is loaded for ALL installed skills on every interaction.
It acts as a **trigger rule**. Include:

1. **WHAT** the skill does (action verbs)
2. **WHEN** to use it (trigger keywords, file types, user phrases)

```yaml
# Good — specific triggers
description: >-
  Create, read, edit, and manipulate Word documents (.docx). Use when
  the user mentions "Word doc", ".docx", or requests professional documents.

# Bad — too vague
description: Helps with documents.
```

Keep descriptions under 200 characters for Claude.ai compatibility.

## Use Templates for Complex Output

For generative skills producing complex artifacts, provide a template file rather
than expecting the agent to create from scratch:

```markdown
**STEP 0:** Read the template at `assets/template.html` FIRST.
Keep all FIXED sections unchanged. Replace only VARIABLE sections.
```

Mark sections with `<!-- === FIXED === -->` and `<!-- === VARIABLE === -->` markers.

## Include QA Steps for Generative Skills

If the skill produces output that can be wrong in non-obvious ways, include a
verification step:

```markdown
## Verification

After generating the document:
1. Validate the XML structure using `scripts/validate.py`
2. Check that all placeholder values have been replaced
3. Verify output matches expected format
```

The best skills assume problems exist and instruct the agent to find them.

## What Distinguishes a Good Skill

Well-structured skills share these traits:

- **Decision trees** — when multiple approaches exist, provide a clear
  task-to-approach mapping so the agent picks the right one
- **Actionable procedures** — step-by-step workflows, not abstract guidance.
  "Do X, then Y, then Z" beats "consider doing X"
- **Concrete examples** — show what the agent should produce, not just how
- **Error prevention** — critical rules and anti-patterns called out BEFORE the
  agent can make the mistake
- **Progressive disclosure** — overview first, details on demand
- **Clear boundaries** — what's in scope, what's not, when to stop

Weakest skills tend to be: vague ("apply good design principles"), overly abstract
(philosophy without procedures), or too thin (a router to examples without enough
connective guidance).

## Sizing Guidelines

| Element | Target Size | Rationale |
|---------|-------------|-----------|
| `description` | 1-2 sentences | Loaded for ALL skills every interaction |
| `SKILL.md` body | 30-80 lines (max 500) | Loaded on activation — keep lean |
| Reference file | 50-200 lines (max ~400) | Focused and useful without wasting context |
| Code asset | Any length | Loaded on demand; should be complete |
| Total skill | 1,500-3,000 lines (max ~5,000) | Split into multiple skills if exceeded |

If a reference file exceeds 200 lines, consider splitting it.

## Pre-Ship Checklist

Before shipping a skill, verify:

- [ ] Directory name matches the `name` field in frontmatter
- [ ] `name` is lowercase alphanumeric + hyphens, max 64 chars
- [ ] `description` specifies WHAT and WHEN (max 200 chars for Claude.ai)
- [ ] `SKILL.md` body is under 500 lines — use reference files for detail
- [ ] Every reference file has YAML frontmatter (`name`, `description`, `tags`)
- [ ] Each reference file covers exactly one concept
- [ ] The "right way" code example appears before any variations
- [ ] Code examples include imports and are copy-paste ready
- [ ] Common mistakes are called out with strong language (FORBIDDEN, NEVER, etc.)
- [ ] Related files cross-reference each other (max one level deep)
- [ ] No reference file exceeds ~400 lines
- [ ] Complex examples are in runnable code assets
- [ ] No hardcoded secrets or credentials
- [ ] Total skill stays under ~3,000-5,000 lines
- [ ] All relative links in SKILL.md resolve to existing files
