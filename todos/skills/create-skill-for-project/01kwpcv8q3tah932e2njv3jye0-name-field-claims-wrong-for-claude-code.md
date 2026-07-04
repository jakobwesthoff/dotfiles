# `name` frontmatter documented as required and as the /command source; both wrong for Claude Code

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md` (frontmatter example line 30, Field Constraints table); `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/SKILL.md` (Critical Rules: "Directory name MUST match the `name` frontmatter field exactly"); `creation-workflow.md` Phase 5 structural checks; `skill-examples.md` ("Bad — name doesn't match directory")

## Current state

- skill-structure.md: `name: my-skill  # Required. Becomes /my-skill command`
- Field Constraints table: `name` marked Required with "Must match directory name."
- SKILL.md Critical Rules: "Directory name MUST match the `name` frontmatter field exactly"

## Problem

Both claims are wrong for Claude Code, which is the product this skill targets:

1. **Not required.** The Claude Code frontmatter reference states "All fields are optional. Only `description` is recommended." `name` is a "Display name shown in skill listings. Defaults to the directory name."
2. **Does not become the command.** "The command you type to invoke a skill comes from where the skill file lives. The frontmatter `name` field sets the display label shown in skill listings and, except for a plugin-root `SKILL.md`, does not change what you type after `/`." A `name`/directory mismatch therefore does not break invocation in Claude Code; the directory name wins.

The strict rule does hold in the Agent Skills open standard (agentskills.io/specification): there `name` is required, max 64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens, and "Must match the parent directory name". Claude Code follows that standard but relaxes these points.

## Grounding

- https://code.claude.com/docs/en/skills (fetched 2026-07-04), "Frontmatter reference" and "How a skill gets its command name" sections; quotes above are verbatim.
- https://agentskills.io/specification (fetched 2026-07-04), `name` field section.

## Proposed change

- Reframe: directory name determines the `/command`; `name` is an optional display label in Claude Code. Recommend still setting `name` equal to the directory name for portability with the open standard (which requires it), and keep the 64-char/lowercase/hyphen format as a spec-portability rule, attributed to the spec rather than presented as a Claude Code hard requirement.
- Update the Critical Rules bullet, the Field Constraints table row, the Phase 5 checks, and the skill-examples.md "Bad" example so they describe the actual failure mode (display/portability inconsistency, not a broken command).
