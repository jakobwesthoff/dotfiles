# Broken relative link in basics.md points to references/advanced-patterns.md from inside references/

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — last line (line 303)

**Current state**:
> For complex multi-line logic, prefer
> [shebang/script recipes](references/advanced-patterns.md).

**Problem**: basics.md already lives in `references/`, so the link resolves to `references/references/advanced-patterns.md`, which does not exist. Correct sibling links use the bare filename.

**Grounding**: `grep -rn 'references/' /Users/jakob/dotfiles/.claude/skills/justfile/references/` returns exactly one hit: `basics.md:303`. `ls /Users/jakob/dotfiles/.claude/skills/justfile/references/` contains `advanced-patterns.md` as a sibling of `basics.md`; there is no nested `references/` directory.

**Proposed change**: Change the link target to `advanced-patterns.md`.
