# Description guidance misses third-person requirement and undertriggering ("pushy" descriptions)

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/writing-principles.md`, "Write a Good Description"; `references/skill-structure.md`, "Description as Trigger Mechanism"; `references/skill-examples.md`, "Good vs Bad Descriptions"

## Current state

Description guidance covers WHAT + WHEN with trigger keywords and length. It says nothing about grammatical point of view or how strongly to word triggers, and the skill-examples.md "Bad — too long" example teaches that longer descriptions are primarily a token-waste problem.

## Problem / opportunity

Two grounded pieces of current official guidance are missing (fetched 2026-07-04):

1. **Third person, always** (platform best-practices, boxed Warning): "Always write in third person. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems." Good: "Processes Excel files and generates reports". Avoid: "I can help you process Excel files" / "You can use this to process Excel files". A cheap, mechanical rule the meta-skill can enforce in its Phase 5 checklist.

2. **Counteract undertriggering** (official skill-creator, anthropics/skills, skills/skill-creator/SKILL.md): "currently Claude has a tendency to 'undertrigger' skills — to not use them when they'd be useful. To combat this, please make the skill descriptions a little bit 'pushy'." Its example expands a one-line description with "Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a 'dashboard.'" The same file also states all "when to use" information belongs in the description, not the body — the body is never seen at trigger time.

Also relevant context from skill-creator's triggering explanation: Claude only consults skills for tasks it can't trivially handle, so keyword-matching alone doesn't guarantee invocation; descriptions should cover intent phrasings, not just nouns.

Item 2 interacts with the skill's 200-char ceiling (separate todo): pushy descriptions need room; the ceiling forces the opposite trade-off.

## Proposed change

In "Write a Good Description": add the third-person rule with the system-prompt rationale; add guidance to err on the side of broader, slightly pushy trigger coverage (phrasings and intents, including cases where the user doesn't name the artifact), noting the model currently undertriggers; state explicitly that all when-to-use information goes in the description because the body is invisible at selection time. Add "description is third person" to the Phase 5 structural checks and Pre-Ship Checklist.
