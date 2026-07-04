# Dynamic Content table never says substitutions and shell injection work only in SKILL.md, not in reference files

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, "Dynamic Content" table (lines 60-66); `references/creation-workflow.md`, Phase 4 Step 2 (reference-file writing instructions, no scoping warning)

## Current state

The Dynamic Content table documents `$ARGUMENTS`, indexed arguments, and `` !`command` `` with no statement about which files they operate in. Phase 4's reference-file instructions never warn against using them there.

## Problem

Substitution and shell injection are invocation-time rendering of the SKILL.md content. The Claude Code docs anchor every mechanism to that rendering step: the lifecycle section defines what enters the conversation as "the rendered `SKILL.md` content"; dynamic context injection "runs shell commands before the skill content is sent to Claude"; "Substitution runs once over the original file." Supporting files take a different path entirely: they sit on disk and are read on demand with file tools, and no rendering step for them is documented anywhere.

The consequence for this meta-skill is direct: it generates Tier 2/3 skills with reference files. If it places `$ARGUMENTS` or `` !`git status` `` in a `references/*.md` file, the generated skill silently delivers the literal placeholder text when that file is read, and nothing in the current guidance would stop it. The failure is invisible in Phase 5's structural checks.

## Grounding

https://code.claude.com/docs/en/skills (fetched 2026-07-04): "Skill content lifecycle" ("the rendered `SKILL.md` content enters the conversation as a single message"), "Inject dynamic context" ("runs shell commands before the skill content is sent to Claude"; "Substitution runs once over the original file"), "Add supporting files" (files "loaded when needed", referenced so Claude knows "when to load" them). The substitution table is documented for skill content only; no official source provides substitution in supporting files.

## Proposed change

Add one line to the Dynamic Content table's intro: substitutions and `` !`command` `` injection apply only to SKILL.md, rendered once at invocation; reference files are read verbatim later, so placeholders there stay literal text. Mirror it as a Phase 4 Step 2 rule (dynamic values belong in SKILL.md; reference files carry only static content) and a Phase 5 check (no `$ARGUMENTS`/`` !`cmd` `` placeholders in `references/`, `assets/`).
