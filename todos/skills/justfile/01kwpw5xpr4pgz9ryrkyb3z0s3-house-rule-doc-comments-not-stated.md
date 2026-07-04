# House rule "recipes need 1-line usage comments" is never stated as a rule

status: needs-grounding

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — "Comments" section
- `/Users/jakob/dotfiles/.claude/skills/justfile/SKILL.md` — "Critical Rules" (candidate location)

**Current state**: basics.md explains doc-comment mechanics in detail:
only the single `#` line immediately above the recipe header is shown in
`just --list`, earlier stacked lines are dropped, with a GOOD/BAD example
pair and the `[doc("…")]` escape hatch. No sentence in the skill instructs
that recipes should *have* a doc comment. A grep for
`doc comment|usage comment` across the skill finds only mechanics
(attributes.md ordering rule, invocation-primer.md's `--list` mention,
and the basics.md section itself).

**Problem**: Dotfiles commit `2132942` (2026-06-30, "Tried to make it
clearer that justfiles need 1-line usage comments") added the GOOD/BAD
mechanics to basics.md, and its title states the underlying intent: that
justfiles need 1-line usage comments. The skill teaches how to format a
doc comment but never that one is expected, so an agent following the
skill can emit a justfile with no doc comments without violating any
stated rule. The skill also does not mark this expectation as a house
convention; `just` itself does not require doc comments, so the rule and
the upstream facts should be distinguishable.

**Grounding**:
- Commit `2132942` in this repo: title above; diff touches only
  `basics.md` and adds mechanics/examples, no affirmative requirement.
- Grep across `/Users/jakob/dotfiles/.claude/skills/justfile/` (2026-07-04)
  as described above: no sentence instructing that recipes get doc
  comments.
- The BAD example's factual claim was re-verified on just 1.55.0: two
  stacked comment lines above `pdf FILE:` → `just --list` prints
  `pdf FILE # without the .md extension.` (only the last line).

**Open question (needs user confirmation)**: the exact scope of the rule
is not recorded anywhere in the repo — every recipe, only public
(non-`[private]`) recipes, and whether modules need doc comments too.

**Proposed change**: Once the scope is confirmed, add one explicit
convention line to basics.md's Comments section (and consider echoing it
in SKILL.md's Critical Rules), phrased as a house convention rather than
a `just` requirement, e.g. "House convention: give every public recipe a
one-line doc comment; it becomes the `--list` description."
