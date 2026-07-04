# Example anti-patterns model bare NEVER rules without reasons, propagating the strong-language mandate into the examples file

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-examples.md`, Tier 1 example anti-patterns (lines 73-74) and Tier 2 spoke rules (lines 155-156)

## Current state

Four example rules give no reason for the prohibition:

- Line 73: `NEVER place tests in a top-level \`__tests__/\` directory.`
- Line 74: `NEVER use \`test()\` — always use \`it()\` inside a \`describe()\` block.`
- Line 155: `NEVER return raw database objects. Always map to a response DTO.`
- Line 156: `NEVER use \`any\` for request bodies — always define a Zod schema.`

(The jest rule on line 63 is the exception: "NEVER use `jest` imports — this project uses Vitest exclusively" carries its why.)

## Problem

Sibling todo `01kwpcv8q3tah932e2njv3jyec` downgrades the blanket strong-language mandate to a calibrated tool, per the official skill-creator guidance to "explain to the model why things are important in lieu of heavy-handed musty MUSTs" and its yellow-flag warning about all-caps ALWAYS/NEVER. That todo rewrites the rule in SKILL.md, writing-principles.md, and creation-workflow.md, but skill-examples.md is not on its file list, and these four lines are the concrete patterns an agent copies. If the rule changes while the examples keep modeling bare all-caps prohibitions, generated skills follow the examples.

## Grounding

- Sibling todo `01kwpcv8q3tah932e2njv3jyec` (grounded against anthropics/skills skill-creator SKILL.md "Writing Style" and improvement guidance; quotes re-verified 2026-07-04 via `gh api`, lines 139 and 302 of that file).
- skill-examples.md lines quoted above.

## Proposed change

Fix in the same pass as the strong-language todo: attach a one-line reason to each example prohibition (e.g. "NEVER use `test()` — this codebase's lint config only recognizes `it()` inside `describe()` blocks", or whatever reason the hypothetical project would have), keeping the register consistent with the reworded rule. The examples should demonstrate the calibrated form: explicit prohibition plus the why.
