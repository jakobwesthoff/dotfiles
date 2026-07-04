# `style()` gained colors, fg:/bg:, stream gates, and a two-arg auto-reset form in 1.55.0

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/functions.md` — "Style" section

**Current state**:
> Valid names: `"command"`, `"error"`, `"warning"`. Returns ANSI escapes matching `just`'s own color scheme.

**Problem**: "Valid names" is now a small subset. On just 1.55.0 the function accepts a much richer style language and a second form that removes the need for the `NORMAL` reset the skill's example depends on.

**Grounding**:
- README `style()` documentation (matches installed 1.55.0):
  - 1.37.0 names: `command`, `error`, `warning`.
  - 1.55.0 additions: named colors (`black`, `blue`, `cyan`, `green`, `magenta`, `red`, `white`, `yellow`); 256 indexed colors as integers `0`–`255`; 24-bit `#RRGGBB`/`#RGB` hex codes; display properties `blink`, `bold`, `dim`, `hidden`, `italic`, `reverse`, `strikethrough`, `underline`; `fg:`/`bg:` prefixes (color styles default to foreground); stream gates `stdout`/`stderr` that emit styles only when just would color that stream (per `--color`/`JUST_COLOR`/TTY).
  - `style(styles, text)` (1.55.0): styles `text` and resets automatically, no `NORMAL` needed.
- Changelog 1.55.0: "Improve `style()` function" (#3478), "Add support for RGB and fixed colors to `style()`" (#3479), "Add stream gates to `style()`" (#3503).
- Local check (just 1.55.0): `sty := style('error')` evaluates to `\e[1;31m`.

**Proposed change**: Rewrite the Style section: keep the three 1.37.0 names as the baseline, then add a 1.55.0+ block covering named/indexed/RGB colors, display properties, `fg:`/`bg:`, stream gates, and the two-argument auto-reset form with a short example (`echo '{{style("error", message)}}'`).
