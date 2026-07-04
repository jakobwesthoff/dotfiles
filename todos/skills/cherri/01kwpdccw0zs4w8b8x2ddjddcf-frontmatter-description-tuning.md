# Frontmatter description: vague trigger phrase "the share sheet integration", missing key trigger keywords

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/SKILL.md`, frontmatter

**Current state**:

```yaml
description: >-
  Write, edit, and debug Cherri (.cherri) iOS Shortcut source files. Use when
  working with Shortcuts, .cherri files, or the share sheet integration.
```

**Problem**: The description is what triggers automatic skill activation.
Issues with the current text:

1. "the share sheet integration" presumes a specific known integration
   (Squirly, named only inside the skill body). Outside that context the
   phrase is meaningless as a trigger and too generic — a user working on
   any app's share-sheet code (e.g. a native iOS app) could false-trigger
   this Cherri-specific skill.
2. "Use when working with Shortcuts" is broad: "shortcuts" also matches
   keyboard-shortcut requests. Qualifying as "Apple Shortcuts" / "iOS
   Shortcuts automation" keeps the trigger and removes ambiguity.
3. Missing natural trigger keywords: "Cherri language", "cherri
   compiler", "compile a shortcut", "Apple Shortcuts", "macOS" (the body
   itself says Cherri targets iOS/macOS, but the description says only
   iOS), "sign a shortcut".

**Grounding**: Anthropic's skill authoring docs
(https://code.claude.com/docs/en/skills, fetched 2026-07-04) state the
description should say "What the skill does and when to use it", advise
"Put the key use case first", and the troubleshooting section's first
check for a skill not activating is "Check the description includes
keywords users would naturally say". The docs also describe description
tuning as generating should-trigger AND should-not-trigger prompts —
i.e., avoiding activation on wrong requests is an explicit goal.
SKILL.md:13-14 says "Cherri is a compiled language that produces signed
`.shortcut` files for iOS/macOS" (macOS missing from the description).

**Proposed change**: Rewrite along the lines of:

```yaml
description: >-
  Write, edit, compile, and debug Cherri (.cherri) source files — a language
  that compiles to Apple Shortcuts for iOS/macOS. Use for .cherri files, the
  cherri compiler, building/signing Apple Shortcuts, or share-sheet shortcut
  development.
```

Tune the exact wording with should-trigger/should-not-trigger examples
(e.g. must NOT trigger on "keyboard shortcuts" requests).
