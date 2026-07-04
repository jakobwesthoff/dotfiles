# actions-and-includes.md contradicts itself on whether `--action` output shows the include category

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`

**Current state**: The "Caveats about `--docs` and `--action`" section
says:

> `--action` and `--docs` do NOT show which `#include` an action
> belongs to.

Forty lines later, the "Include system" section says:

> When unsure which include an action needs, use
> `cherri --action=actionName --no-ansi` — the output shows the
> category.

**Problem**: Direct contradiction inside one file; the second statement
is the false one. An agent following it will run `--action` expecting a
category and find none, then have no strategy for locating the right
include.

**Grounding** (local verification, Cherri Compiler v2.1.0, 2026-07-04):
`cherri --action=jsonRequest --no-ansi` prints only the doc title,
description, enum, and signature — no category or include information.
Same for every other action looked up during this review
(`downloadURL`, `speak`, `hash`, `randomNumber`, `formatNumber`, ...).

**Proposed change**: Delete or rewrite the "the output shows the
category" sentence. Correct guidance: `--action` confirms an action
exists and gives its signature but NOT its include; to find the include,
search `--docs=<category>` per candidate category (unreliable — some
actions are missing from all category listings, e.g. `randomNumber`), or
definitively `grep -l <actionName>` over the compiler source checkout's
`actions/*.cherri` directory (see the formatNumber quirk todo for the
verified technique).
