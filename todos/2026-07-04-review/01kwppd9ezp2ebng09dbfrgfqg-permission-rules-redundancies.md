# Permission allow-lists carry redundant and dead rules across the three settings files

**Area**: claude-config
**Files**: /Users/jakob/dotfiles/.claude/settings.json lines 3-18; /Users/jakob/dotfiles/.claude/settings.local.json (untracked); /Users/jakob/.claude/settings.local.json (outside repo)

All rule syntax is valid; current docs confirm the space form and the
`:*` form are equivalent: "The `:*` suffix is an equivalent way to
write a trailing wildcard, so `Bash(ls:*)` matches the same commands as
`Bash(ls *)`" (https://code.claude.com/docs/en/permissions). The issues
are redundancy and dead entries, not syntax.

## Occurrences

1. **Exact-match rules shadowed by a prefix rule** — user settings
   (`settings.json` lines 15-17):

   ```
   "Bash(mkulid -l -n 8)",
   "Bash(mkulid -l)",
   "Bash(mkulid:*)"
   ```

   `Bash(mkulid:*)` covers both exact rules.

2. **Rules duplicating the built-in read-only command set** — user
   settings has `Bash(ls:*)`, `Bash(grep:*)`, `Bash(wc:*)`,
   `Bash(find:*)`; the dotfiles-project `settings.local.json` adds
   `Bash(brew --version)` style one-offs; `~/.claude/settings.local.json`
   has `Bash(cat:*)`, `Bash(echo:*)`. Docs: "Claude Code recognizes a
   built-in set of Bash commands as read-only and runs them without a
   permission prompt in every mode. These include `ls`, `cat`, `echo`,
   `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`,
   `stat`, `du`, `cd`, and read-only forms of `git`." The explicit
   rules add value only for invocations outside the read-only handling
   (e.g. unquoted globs on write-capable commands); for `find`, even an
   explicit rule never covers `-exec`/`-delete` ("a `Bash(find *)` rule
   doesn't cover these forms").

3. **Cross-scope duplicate** — the dotfiles-project
   `.claude/settings.local.json` allows `Bash(git *)` while user
   settings already allow `Bash(git:*)`; the local rule is fully
   shadowed. `WebSearch` is likewise allowed in both `settings.json`
   and `~/.claude/settings.local.json`.

4. **Dead compound-command fragments** — `~/.claude/settings.local.json`
   contains rules saved from approving a multiline shell loop:

   ```
   "Bash(while read ts)",
   "Bash(do python3 -c \"from datetime import datetime; print(datetime.fromtimestamp($ts))\")",
   "Bash(done)"
   ```

   These are exact-match rules for fragments that only recur if the
   identical loop is typed again; `$ts` in the middle rule makes it
   effectively unmatchable. Junk from a one-off approval.

## Grounding

- File contents read 2026-07-04 (quoted above).
- https://code.claude.com/docs/en/permissions — wildcard equivalence,
  built-in read-only set, and find `-exec`/`-delete` behavior (quotes
  inlined above).

## Proposed change

- Drop the two exact `mkulid` rules (keep `Bash(mkulid:*)`).
- Drop `Bash(git *)` from the dotfiles-project `settings.local.json`.
- Delete the three loop-fragment rules from
  `~/.claude/settings.local.json`.
- Optionally prune the read-only-command rules (`ls`, `grep`, `wc`,
  `cat`, `echo`, `find`); keep any where auto-approval of glob-heavy
  invocations is specifically wanted.
