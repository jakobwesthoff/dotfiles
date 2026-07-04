# "Each file can only be included once" is confirmed — and applies to action categories across the whole include tree

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "Including Cherri files"

**Current state**:

> - File must exist and have `.cherri` extension
> - Each file can only be included once
> - Use `..` for parent directory paths

The claim was flagged as never-validated by the first-pass review. It is
listed only under "Including Cherri files", implying it concerns user
`.cherri` files.

**Problem / opportunity**: The claim is true, but understated in two ways
that matter for multi-file projects:

1. The rule covers ALL include paths, including `actions/...` categories
   and `stdlib`, not just user `.cherri` files. `#include 'actions/web'`
   twice in one file is a hard compile error.
2. The dedup is global across the whole include tree: if the main file
   includes `actions/web` and an included helper `.cherri` file also
   includes `actions/web`, compilation fails. Splitting code into helper
   files therefore requires all action-category includes to live in
   exactly one place (in practice: the main file), and helper files must
   not carry their own includes for categories the main file uses.

**Grounding** (Cherri Compiler v2.1.0, commit 2ca7dfe, verified
2026-07-04):

- Compiler source `includes.go:97-99` (checkout
  `/Users/jakob/Development/github/electrikmilk/cherri`):

  ```go
  if slices.Contains(included, includePath) {
      parserError(fmt.Sprintf("Path '%s' has already been included.", includePath))
  }
  ```

  The `included` list is global and appended for every resolved include
  (`includes.go:135`), regardless of whether the path is a user file, an
  `actions/...` category, or `stdlib`.
- Test compiles (all exit 1):
  - Same user file included twice:
    `Error: Path 'helper.cherri' has already been included. (1:24)`
  - `#include 'actions/web'` twice in one file:
    `Error: Path 'actions/web' has already been included. (1:22)`
  - Main file includes `actions/web` AND a helper `.cherri` that itself
    includes `actions/web`:
    `Error: Path 'actions/web' has already been included. (1:22)`

**Proposed change**: In the "Including Cherri files" section, extend the
bullet to the verified rule: every include path (user files, action
categories, `stdlib`) may appear only once across the entire include
tree; the error is `Path 'X' has already been included.`. Add one line of
guidance for multi-file projects: keep all `actions/...`/`stdlib`
includes in the main file and none in helper files.
