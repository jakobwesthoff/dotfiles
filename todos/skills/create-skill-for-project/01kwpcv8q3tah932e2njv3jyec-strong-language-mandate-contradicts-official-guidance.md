# Blanket "strong language" mandate (FORBIDDEN/NEVER/MUST NOT) contradicts current official authoring guidance

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/SKILL.md` (Critical Rules: "Include anti-patterns with strong language (FORBIDDEN, NEVER, MUST NOT)"); `references/writing-principles.md` ("State Anti-Patterns Explicitly": "Use: `FORBIDDEN`, `NEVER`, `MUST NOT`, `DO NOT`." and Pre-Ship Checklist "Common mistakes are called out with strong language"); `references/creation-workflow.md` (Phase 4 Step 2 "Anti-patterns (FORBIDDEN, NEVER, MUST NOT)"; Phase 5 "Anti-patterns use strong language"; Common Pitfalls "Missing Anti-Patterns")

## Current state

Strong-language anti-patterns are mandated in every skill: a Critical Rule, a required section of the reference-file anatomy, and pass/fail items in two checklists.

## Problem

Anthropic's current authoring guidance treats all-caps absolutes as a fallback, not a default:

- The official skill-creator skill (anthropics/skills, skills/skill-creator/SKILL.md, fetched 2026-07-04), "Writing Style": "Try to explain to the model why things are important in lieu of heavy-handed musty MUSTs." And under "Improving the skill": "If you find yourself writing ALWAYS or NEVER in all caps, or using super rigid structures, that's a yellow flag — if possible, reframe and explain the reasoning so that the model understands why the thing you're asking for is important." It also warns against "oppressively constrictive MUSTs" as overfitting when iterating.
- The platform best-practices doc (fetched 2026-07-04) positions stronger language as an escalation after observed failures: Claude A "might suggest ... using stronger language like 'MUST filter' instead of 'always filter'" when testing shows a rule being missed. It does not recommend starting there.

Explicitly forbidding known-bad patterns remains legitimate (best-practices supports explicit anti-patterns, e.g. "Avoid offering too many options", and escalation after failures), so the finding is about the mandate and default register, not about dropping anti-pattern sections.

## Proposed change

- Downgrade from mandate to calibrated tool: state anti-patterns explicitly, with a one-line reason for why the wrong way fails ("explain the why"), and reserve ALL-CAPS absolutes for rules that testing shows are otherwise ignored or whose violation is destructive.
- Reword the Critical Rules bullet, the reference-file anatomy item, and both checklist items accordingly (e.g. "Common mistakes are called out explicitly with the reason they fail").
- Keep the existing good examples (the `setTimeout`/`useCurrentFrame()` example already includes the why: "they will not render correctly").
