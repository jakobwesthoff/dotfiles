# "Relative paths from the skill root" link rule is ambiguous, contradicted by one example, and modeled as a broken link by another

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/writing-principles.md`, "Cross-Reference Related Files", first rule bullet (line 82); `references/skill-examples.md`, Tier 2 spoke link (line 158) and Tier 3 asset link (line 184); `references/creation-workflow.md`, Phase 4 Step 2 item 4 ("Cross-reference related files with relative links", line 171, no base stated)

## Current state

- writing-principles.md rule: "Use relative paths from the skill root"
- skill-examples.md, inside `references/endpoint-patterns.md` (a file in `references/`): `For error responses, see [references/error-handling.md](references/error-handling.md).` — skill-root-relative.
- skill-examples.md, inside `references/form-components.md`: `see [assets/form-select.tsx](../assets/form-select.tsx)` — containing-file-relative (`../`).

## Problem

The two examples follow opposite conventions, and the stated rule endorses the one that produces broken links. Markdown relative links resolve against the containing file's location (this is how GitHub, editors, and every markdown renderer treat them). From `references/endpoint-patterns.md`, the link target `references/error-handling.md` resolves to `references/references/error-handling.md`, which does not exist. The Tier 3 example's `../assets/form-select.tsx` resolves correctly.

Consequences for generated skills: an agent following the "from the skill root" rule writes spoke-to-spoke and spoke-to-asset links that fail as markdown, and the skill's own Phase 5 check "All relative links in SKILL.md resolve to existing files" never catches them because it only checks SKILL.md.

For SKILL.md itself the two conventions coincide (SKILL.md sits at the skill root), which is why the official docs' examples (`[reference.md](reference.md)` from SKILL.md; `[reference/finance.md](reference/finance.md)` from SKILL.md) never surface the ambiguity. No official source prescribes a base for links inside supporting files; the platform best-practices doc instead recommends keeping references one level deep so all files link directly from SKILL.md, which sidesteps the problem.

## Grounding

- Renderer behavior: markdown relative links resolve against the containing document (GitHub docs, "Relative links ... are resolved relative to the current file"); verified against the two example spots quoted above, one of which breaks under that resolution.
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices (fetched 2026-07-04): "Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md"; all link examples originate in SKILL.md.
- https://code.claude.com/docs/en/skills (fetched 2026-07-04): supporting-file examples link from SKILL.md only.

## Proposed change

Restate the rule as: relative links resolve from the file that contains them; from SKILL.md that equals the skill root, from a file in `references/` use `../` to reach siblings' directories (or link peers as bare `error-handling.md` within the same directory). Fix skill-examples.md line 158 to `[error-handling.md](error-handling.md)`. Extend the Phase 5 link check to all markdown files in the skill, not just SKILL.md.
