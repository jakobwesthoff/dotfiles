# Squirly-specific content is baked into a dotfiles-level Cherri skill

**Skill**: cherri
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/cherri/SKILL.md`, "When to use": "...or working on the Squirly share sheet integration."
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/share-sheet-shortcut.md`: entire file is a Squirly-specific pattern (Squirly API URL/token questions, `{storedApiUrl}/api/v1/bookmarks` endpoint, "The Squirly settings page should..." product requirements).
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/shortcut-metadata.md`, sections "Import questions (first-run setup)" and "Complete share sheet shortcut metadata": Squirly-named examples.

**Current state**: The skill mixes two scopes: general Cherri language
knowledge (6 reference files) and one project's integration recipe. The
Squirly project does not live in the dotfiles repo — `grep -rl Squirly
/Users/jakob/dotfiles --include='*.md'` matches only the three skill
files above.

**Problem**:
1. The skill is available in every session started from dotfiles-managed
   locations, so unrelated Cherri work gets Squirly-flavored guidance
   (e.g. an agent asked to build any share-sheet shortcut may reproduce
   the `/api/v1/bookmarks` endpoint or Squirly naming).
2. share-sheet-shortcut.md ends with product requirements for the
   Squirly settings page (token generation, download link) — that is
   Squirly project documentation, not Cherri knowledge, and it will drift
   as the Squirly project evolves with no mechanism to keep it in sync.
3. The complete example in share-sheet-shortcut.md currently does not
   compile (see the jsonRequest const-dict todo), which illustrates the
   drift risk of duplicating project recipes here.

**Grounding**: Anthropic's skills docs
(https://code.claude.com/docs/en/skills, fetched 2026-07-04) distinguish
personal skills ("available in all your projects") from project skills
("shared with everyone who works in that repository") — scope determines
placement. File contents quoted from the three files listed above; grep
output from 2026-07-04.

**Proposed change** (needs a decision by Jakob):
- Option A: Move share-sheet-shortcut.md (and the Squirly example block
  in shortcut-metadata.md) into the Squirly project's own
  `.claude/skills/`, leaving the dotfiles skill purely
  language-focused with a generic share-sheet example.
- Option B: Genericize in place — rename to "share-sheet API bookmark
  pattern", replace Squirly naming with a placeholder API, and drop the
  "Squirly settings page should" product-requirements section.
Either way, remove "the Squirly share sheet integration" from SKILL.md's
"When to use" (see also the frontmatter description todo).
