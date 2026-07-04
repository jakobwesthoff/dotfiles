# Missing core official concept: degrees of freedom (matching instruction specificity to task fragility)

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/writing-principles.md` (whole file; "Be Prescriptive, Not Descriptive" is the closest existing section); `references/creation-workflow.md` Phase 3 (design decisions: archetype and tier only)

## Current state

The writing guidance is uniformly maximal-specificity: prescriptive style, code-first, copy-paste-ready blocks, explicit prohibitions. Nothing tells the author when to leave the executing agent latitude.

## Problem / opportunity

"Set appropriate degrees of freedom" is a top-level core principle in the platform best-practices doc (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices, fetched 2026-07-04), and the skill omits it entirely:

- **High freedom** (text instructions): multiple approaches valid, decisions depend on context, heuristics guide the approach. Example given: code review as numbered heuristic steps.
- **Medium freedom** (pseudocode or scripts with parameters): a preferred pattern exists, some variation acceptable.
- **Low freedom** (specific scripts, few or no parameters): "Operations are fragile and error-prone; consistency is critical; a specific sequence must be followed." Example: "Run exactly this script... Do not modify the command or add additional flags."
- The doc's analogy: a narrow bridge with cliffs needs exact guardrails; an open field needs only general direction.

The same doc's "Concise is key" principle ("Default assumption: Claude is already very smart. Only add context Claude doesn't already have") is the counterweight to this skill's "every skill must be fully prescriptive" stance. The official skill-creator similarly says to "make the skill general and not super-narrow to specific examples" (anthropics/skills, skills/skill-creator/SKILL.md, fetched 2026-07-04).

Without this concept, the meta-skill steers every generated skill toward low-freedom instructions even for judgment-heavy domains (reviews, design, naming), where official guidance says that over-constrains the model.

## Proposed change

Add a "Degrees of freedom" section to writing-principles.md with the three-level table and the fragility criterion, and a Phase 3 design decision in creation-workflow.md: for each topic the skill covers, decide whether it is a fragile sequence (low freedom: exact commands/scripts), a preferred pattern (medium: template with variation points), or judgment-guided (high: heuristics and goals). Cross-link from "Be Prescriptive, Not Descriptive" so prescriptiveness is framed as the low-freedom end of a spectrum rather than the universal rule.
