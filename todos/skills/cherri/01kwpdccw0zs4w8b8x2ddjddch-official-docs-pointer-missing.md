# No pointer to the official language documentation for topics the skill does not cover

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/SKILL.md` (and the reference files generally)

**Current state**: The skill directs agents to the `cherri` CLI for
action lookups ("ALWAYS use the `cherri` CLI to look up action
signatures") and to glyphs.cherrilang.org for glyphs
(shortcut-metadata.md). No file links the official language documentation
at https://cherrilang.org/language/.

**Problem**: For language-level questions the skill does not answer, an
agent has no sanctioned fallback and may hallucinate syntax. The CLI only
documents actions/glyphs, not language syntax. Topics documented at
cherrilang.org/language/ but absent from or only touched by the skill:
standalone enumerations (enums.html), operators (operators.html), menus
detail (menus.html), content references / `#ref` (references.html,
requires >= v2.3.0), the package manager (`--init`, `--install`,
`--tidy`; package-manager.html + `cherri --help`), and comments
(comments.html — see separate todo).

**Grounding**: cherrilang.org/language/ fetched 2026-07-04; it lists 20
documentation pages (Actions, Comments, Definitions,
Variables/Constants/Globals, Content References, Types, Control Flow,
Enumerations, Menus, Operators, vCard Menus, Copy/Paste, Import
Questions, Import Actions, Includes, Functions, Action Definitions,
Packages, Raw Actions, Best Practices). glyphs.cherrilang.org also
resolves (a "Shortcuts Glyph Search" page), so the skill's existing link
is alive. Caveat verified during this review: the site tracks the latest
release, and at least one documented feature (`isToday` conditional,
control-flow.html) is rejected by the installed v2.1.0 compiler (`Error:
Invalid conditional 'isToday'`), so the docs pointer must carry a
version warning.

**Proposed change**: Add one short paragraph to SKILL.md (e.g. under
"Looking up actions"): for language syntax not covered by this skill,
consult https://cherrilang.org/language/ — but note the site documents
the latest compiler release; verify anything taken from it against the
installed compiler with a test compile (the installed version can be
checked with `cherri -v`).
