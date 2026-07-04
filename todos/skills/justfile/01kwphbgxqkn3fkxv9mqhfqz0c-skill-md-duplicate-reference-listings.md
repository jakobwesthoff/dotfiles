# SKILL.md lists all nine reference files twice (Decision Tree + Reference Files sections)

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/SKILL.md` — "Decision Tree" table and "Reference Files" list

**Current state**: The Decision Tree table (task → file) and the closing "Reference Files" bullet list (file → content summary) enumerate the same nine files with overlapping descriptions.

**Problem**: SKILL.md content stays in context for the rest of the session once the skill is invoked, so every line is a recurring token cost. The two listings convey nearly the same routing information; only the phrasing differs (task-oriented vs. content-oriented).

**Grounding**:
- Anthropic skill docs (code.claude.com/docs/en/skills, fetched 2026-07-04): "Keep the body itself concise. Once a skill loads, its content stays in context across turns, so every line is a recurring token cost." and "Reference supporting files from `SKILL.md` so Claude knows what each file contains and when to load it" — one listing satisfies that requirement.
- Both listings verified present in the current SKILL.md (lines 23–35 and 76–87).

**Proposed change**: Merge into a single table with two informative columns, e.g. `file | when to open it (task) + one-line content summary`, and delete the other section. Keeps routing quality while removing ~10 duplicated lines.

Secondary observation (cosmetic): the nine reference files each carry YAML frontmatter (`name`, `description`, `metadata.tags`). The skills documentation defines frontmatter for SKILL.md only; for supporting files it has no effect on activation and just adds a few lines of tokens whenever a reference file is read. Harmless — remove only if trimming.
