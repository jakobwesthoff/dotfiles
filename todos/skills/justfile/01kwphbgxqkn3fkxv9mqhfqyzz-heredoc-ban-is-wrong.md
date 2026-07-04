# Heredocs work fine in shebang and `[script]` recipes; the skill's "NEVER use heredocs" claim is false

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/advanced-patterns.md` — "Body tokenization caveat" section

**Current state**:
> NEVER use shell heredocs (`<<EOF … EOF`) inside shebang or script recipes. The heredoc body is parsed as justfile content, and barewords or assignment-like lines trigger parse errors. Use `printf`, `echo`, or the interpreter's native string handling instead.

**Problem**: The claim is false on just 1.55.0. Recipe body lines (including heredoc content) are ordinary body text as long as they keep the recipe's indentation; they are not parsed as justfile items, and shebang/script bodies are dedented before being written to the temp file, so even the closing `EOF` delimiter works while indented. The ban steers authors away from a working pattern and asserts a wrong parse model.

**Grounding**: Local tests (just 1.55.0), both exit 0 with correct output:
```just
hd:
  #!/usr/bin/env bash
  cat <<EOF
  hello from heredoc
  value = 1
  EOF
  echo done
```
printed the heredoc body (with `value = 1` bareword line) and `done`. The same body under `[script("bash")]` also worked. The dedent behavior follows from just writing the recipe body to a temp file for shebang/script recipes (README "Script and Shebang Recipe Temporary Files").

**Proposed change**: Replace the NEVER-heredoc paragraph with the real constraints:
1. Heredocs work in shebang and `[script]` recipes because the body is dedented and written to a temp file; all heredoc lines (including the terminator) must keep at least the recipe's indentation, since a less-indented line ends the recipe body.
2. `{{` inside heredoc text is still interpolated (or a parse error if unterminated) — the existing `{{`-in-comment caveat in the same section covers this and remains correct (verified locally: `# comment with {{` in a `[script]` body fails with `error: unterminated interpolation`).
3. Heredocs cannot be used in linewise recipes, where each line is a separate shell invocation (existing skill fact, still correct).
