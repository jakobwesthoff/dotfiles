# Settings expressions are const-context: variable rule missing, and the anti-pattern's "CORRECT" fix is a dead end

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/settings.md` — intro paragraph and "Anti-Patterns" section

**Current state**:

Intro:
> Since 1.46.0, non-boolean settings accept expressions, but those
> expressions MUST NOT contain backticks or function calls.

Anti-Patterns:
> ```just
> # BROKEN — backticks not allowed in settings
> set working-directory := `pwd`
>
> # CORRECT — use a variable
> dir := `pwd`
> ```

**Problem**:
1. The intro rule is incomplete. Setting values are evaluated in a const
   context: besides backticks and function calls, references to non-const
   variables are also rejected. References to variables that are
   themselves const (built from literals/operators) are allowed, which the
   skill does not mention.
2. The anti-pattern's "CORRECT" alternative does not accomplish the
   original goal. Assigning `dir := `pwd`` produces a non-const variable
   that cannot be used in `set working-directory` either, and the example
   ends after the assignment, leaving the reader with no working path to a
   dynamic working directory.

**Grounding** — local tests, just 1.55.0:
- `set working-directory := 'a' + 'b'` → recipe ran with `pwd` ending in
  `/ab` (exit 0). Operator expressions work.
- `set working-directory := replace('subx', 'x', '')` →
  `error: cannot call functions in const context` (exit 1).
- `dir := 'sub'` then `set working-directory := dir` → recipe ran with
  `pwd` ending in `/sub` (exit 0). Const variable references work.
- `dir := `echo sub`` then `set working-directory := dir` →
  `error: cannot access non-const variable `dir` in const context`
  (exit 1). Identical error when `dir` is defined via a function call
  (`dir := replace('subx', 'x', '')`).
- Working dynamic alternative at recipe level:
  `[working-directory(justfile_directory() / 'axsub')]` ran with `pwd`
  = `…/axsub` (exit 0) — attribute arguments accept function calls,
  unlike settings (expressions in these attributes are also covered by
  todo `01kwphbgxqkn3fkxv9mqhfqz0h`).

**Proposed change**:
1. Reword the intro rule: setting values must be const expressions — no
   backticks, no function calls, no references to non-const variables;
   referencing a variable that is itself const is allowed.
2. Fix the anti-pattern: state that a setting value cannot be dynamic,
   and show the working alternatives instead of the dead-end variable
   assignment: per-recipe `[working-directory(expression)]` (expressions
   allowed there), or changing directory inside the recipe.
