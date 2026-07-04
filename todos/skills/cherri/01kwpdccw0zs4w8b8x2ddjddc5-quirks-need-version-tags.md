# compiler-quirks.md entries carry no compiler version, so they cannot age out

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md` (whole file)

**Current state**: The file documents 20 quirks/bugs with hedges like "Some
compiler versions have a broken `seek` action definition" and "may be
empty (compiler bug)", but no entry states which compiler version the
behavior was observed on, and the file has no note about how to re-verify.

**Problem**: Quirks are inherently version-specific. At least one entry is
already stale (the `const` + boolean-action panic does not reproduce on
v2.1.0; see companion todo), while others remain fully reproducible on
v2.1.0. Without version stamps, a future reader cannot tell which
workarounds are still needed, and stale workarounds accumulate.

**Grounding** (local verification, 2026-07-04): `cherri -v` reports
`Cherri Compiler v2.1.0`; the binary is built from a local source checkout
at `/Users/jakob/Development/github/electrikmilk/cherri`, commit `2ca7dfe`
(2026-01-24, 18 commits after the `v2.1.0` tag). Reproduction status
verified per entry on this build:

- REPRODUCES: action call in expression ("Value of type 'action' not
  allowed in expression"); action output in comparison ("Invalid type
  'action' for conditional '<'"); `actions/music` include broken ("Unknown
  type 'timerDuration'", actions/music:87:27); globals-to-const ("Type
  variable values cannot be constants."); number/float strictness
  ("Invalid value 0.2 (float) for argument 'seconds' (number)."); menu
  bare-string ("Illegal character '\"'"); no `break` ("Illegal character
  'b'"); nested action call = Go panic (exit 2, `interface conversion:
  interface {} is main.action, not main.varValue` in
  `makeActionParams`); `--docs=photos` prints only the category header
  with zero actions; `-o=` flag ignored (no output file at the given path,
  default-named file written instead — verified both with and without
  `#define name`); bracket syntax on const ("Type variable values cannot
  be constants."); inline `#question` reference ("Undefined inline
  reference 'token'"); `runShellScript(text script, variable input, ...)`
  — `input` has no `?`, confirmed required.
- DOES NOT REPRODUCE: `const charging = isCharging()` compiles cleanly.

Upstream fix status (from `gh api repos/electrikmilk/cherri/releases`
release notes, retrieved 2026-07-04):

- `actions/music` breakage: fixed in v2.1.1 ("Fix timerDuration type not
  found in actions/music", PR #159).
- Misleading include suggestions: fixed in v2.2.0 ("The compiler now
  figures out the right include you need ... we were blocking some
  includes based on a bad regex").
- Action outputs in comparisons: v2.1.1 "allows using the expression
  result as a number in `if` comparisons"; v2.2.0 expands conditional
  types (dates, quantities) — entry needs re-verification after upgrade.

**Proposed change**: Add a header line to compiler-quirks.md recording the
verified compiler version (v2.1.0, commit 2ca7dfe) and the verification
date, plus one line explaining that entries were reproduced against that
build and should be re-tested after a compiler upgrade. Tag the entries
listed above with their upstream fix version. Remove or version-scope the
non-reproducing `const` + boolean-action entry per its own todo.
