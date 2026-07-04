# Comment syntax is never documented (block comments and comment() action missing)

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/language-fundamentals.md` (best fit; currently no file covers comments)

**Current state**: Examples throughout the skill use `//` comments, and
patterns-and-practices.md documents the `--comments` flag ("Include //
comments as Shortcut comment actions"), but no file states the comment
syntax itself. Block comments and the explicit comment action are absent
entirely.

**Problem**: An agent has to infer comment syntax from examples; `/* */`
and `comment()` are undiscoverable from the skill.

**Grounding**: cherrilang.org/language/comments.html (fetched 2026-07-04):
- Single-line comments: `//`.
- Multi-line/block comments: `/* */`.
- Comments are excluded from compiled shortcuts by default to minimize
  file size; the `--comments` (`-c`) flag includes them as comment
  actions.
- A `comment()` action adds a comment action to the shortcut regardless
  of the flag.
Local cross-check (Cherri Compiler v2.1.0, 2026-07-04): `cherri --help`
lists `-c --comments  Include comment actions in compiled Shortcut or
import.` Test compile confirms `//`, `/* */`, and `comment('...')` all
compile. `comment()` is typed `comment(rawtext text)`: it requires a
single-quoted argument — `comment("...")` fails with `Invalid value ...
(text) for argument 'text' (rawtext).`

**Proposed change**: Add a short "Comments" subsection to
language-fundamentals.md: `//` and `/* */` syntax, default exclusion from
compiled output, `--comments`/`-c` to include them, and `comment('...')`
(single quotes mandatory — rawtext parameter) for comments that must
always appear in the compiled Shortcut.
