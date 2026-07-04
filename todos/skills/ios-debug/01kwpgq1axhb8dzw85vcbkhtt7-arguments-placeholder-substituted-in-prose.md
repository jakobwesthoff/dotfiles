# `$ARGUMENTS` embedded mid-sentence gets substituted, garbling the tip

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Tips", last bullet

**Current state**:

> - If $ARGUMENTS contains a URL, look for a matching tab in `opened-tabs`
>   output and focus debugging there.

**Problem**: `$ARGUMENTS` in a SKILL.md body is not prose — Claude Code replaces it with the literal argument string at invocation time. Invoked as `/ios-debug https://example.com`, the model receives "If https://example.com contains a URL, look for a matching tab ..."; invoked with no arguments, the conditional's subject vanishes. The sentence was written as if the model would see the placeholder name and reason about it.

**Grounding**: Claude Code skills documentation (https://code.claude.com/docs/en/skills), "Available string substitutions": "`$ARGUMENTS` — All arguments passed when invoking the skill. If `$ARGUMENTS` is not present in the content, arguments are appended as `ARGUMENTS: <value>`." Same page, escaping rules: "To include a literal `$` before a digit, `ARGUMENTS`, or a declared argument name ... escape it with a backslash: `\$1.00`."

**Proposed change**: Pick one:
1. Restructure so the substituted value reads naturally, e.g. a dedicated block at the top of the skill:

   ```markdown
   ## Invocation arguments

   $ARGUMENTS

   If the arguments above contain a URL, look for a matching tab in
   `opened-tabs` output and focus debugging there.
   ```

2. Or drop the placeholder entirely (`\$ARGUMENTS` escaping would keep the literal text, but per the docs the arguments then get appended as `ARGUMENTS: <value>` at the end anyway, so option 1 is cleaner): "If the user's request contains a URL, look for a matching tab ...", relying on the appended `ARGUMENTS:` line.
