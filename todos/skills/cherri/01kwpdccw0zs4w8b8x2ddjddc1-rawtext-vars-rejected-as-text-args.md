# Missing quirk: single-quoted (rawtext) variables are rejected by `text`-typed action parameters

**Skill**: cherri
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/language-fundamentals.md`, section "Raw text (no interpolation)"
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/patterns-and-practices.md`, section "Use raw text when interpolation isn't needed"
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md` (new entry)

**Current state**: The skill recommends single-quoted raw text for speed:

> Single-quoted strings skip interpolation and compile faster:
> ```ruby
> @raw = 'i\'m not allowed inline variables, new lines, etc. but i compile faster!'
> ```

and patterns-and-practices.md labels `@msg = 'Hello, world!'` as "FASTER"
vs `@msg = "Hello, world!"` as "SLOWER". Neither file warns that a variable
holding raw text has type `rawtext` and cannot be passed where actions
expect `text`.

**Problem**: An agent following the "prefer raw text" efficiency advice
will produce variables that fail to compile as soon as they are passed to a
normal action parameter. The advice is a trap without the type caveat.

**Grounding** (local verification, Cherri Compiler v2.1.0, 2026-07-04):

```ruby
@plain = 'abc'
alert(@plain, "Title")
```

fails with:

```
Error: Invalid variable value abc (rawtext) for argument 'alert' (text).
```

Declaring the same variable and not passing it anywhere compiles fine.
`rawtext` is a real declared type: the compiler's "Available types" list
(printed on a type error) is `text, rawtext, number, float, bool, array,
dictionary, variable, color`.

**Proposed change**: Add a compiler-quirks entry ("rawtext variables are
rejected by `text` parameters") with the exact error message, and qualify
the raw-text efficiency advice in both language-fundamentals.md and
patterns-and-practices.md with the verified caveat: a variable assigned a
single-quoted string has type `rawtext` and cannot later be passed to an
action parameter typed `text`. Before finalizing the wording, determine by
test-compilation which uses of a rawtext variable DO work (interpolation
into a double-quoted string, comparison in `if`, etc.) so the guidance
states the safe scope rather than only the failure.
