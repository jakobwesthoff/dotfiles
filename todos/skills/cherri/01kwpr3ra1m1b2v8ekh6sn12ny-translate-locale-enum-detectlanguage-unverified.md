# detectLanguage/translate quirk: translate's locale-code restriction is a strict compile-time enum; the detectLanguage return-format claim is unvalidated

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md`, section "`detectLanguage()` returns human-readable names"

**Current state**:

> Returns `"English"`, `"German"`, etc. — NOT locale codes like `en_US`.
> But `translate()` uses locale codes for `to`/`from`. Plan accordingly.

The first-pass review could not reproduce or ground either half.

**Problem / opportunity**: The two halves of this quirk have very
different evidence status, and the entry documents neither the exact
accepted values nor the error an agent will see.

1. The `translate()` half is verifiable and true at compile time, but
   stronger than "uses locale codes": `to`/`from` are typed with a strict
   enum of exactly 19 locale codes, and any other string literal is a
   compile error. Two of the codes are nonstandard (`jp_JP` instead of
   ISO `ja_JP`, `vn_VN` instead of `vi_VN`), so an agent generating
   "correct" ISO codes for Japanese or Vietnamese will fail.
2. String literals are validated against the enum, but variable
   references bypass the check and compile. Passing `detectLanguage()`
   output to `translate()` compiles; whether it works at runtime depends
   on the unvalidated return-format claim.
3. The `detectLanguage()` half ("returns `English`, not locale codes")
   is a runtime claim with no source. It cannot be validated by
   compilation, no upstream issue documents it (GitHub issue search for
   "detectLanguage" in electrikmilk/cherri returns nothing, 2026-07-04),
   and a web search found no authoritative statement of the action's
   output format.

**Grounding** (Cherri Compiler v2.1.0, commit 2ca7dfe, verified
2026-07-04):

- Bundled definitions (checkout
  `/Users/jakob/Development/github/electrikmilk/cherri`):
  - `actions/translation.cherri:6-10`: `translate(text text: 'WFInputText',
    language to: 'WFSelectedLanguage', language ?from:
    'WFSelectedFromLanguage' = "Detected language"): text`
  - `actions/translation.cherri:13`: `detectLanguage(text input:
    'WFInput'): text`
  - `actions/basic.cherri:10-30`: `enum language` = `ar_AE, zh_CN, zh_TW,
    nl_NL, en_GB, en_US, fr_FR, de_DE, id_ID, it_IT, jp_JP, ko_KR, pl_PL,
    pt_BR, ru_RU, es_ES, th_TH, tr_TR, vn_VN`
- Test compile: `translate(@t, "English")` fails with
  `Error: Invalid value 'English' for argument 'to'.` and prints the full
  enum.
- Test compile: `const lang = detectLanguage(@t)` then
  `translate(@t, lang)` compiles (exit 0). Variables are exempt from enum
  validation (commit `b865519` "Improve enum error message and allow
  string variables for enum value" is in the installed build).

**Unvalidated**: the claim that `detectLanguage()` returns `"English"` /
`"German"` at runtime. Needed to settle it: compile a shortcut that runs
`detectLanguage()` on known text and shows the raw result, run it once
on-device, and record the output.

**Proposed change**: Rewrite the quirk entry: state that `translate()`'s
`to`/`from` accept only the 19 enum locale codes above (inline the list;
call out `jp_JP`/`vn_VN`), quote the `Invalid value ... for argument 'to'`
error, and note that variable arguments skip the enum check so
locale-code mistakes surface only at runtime. Keep the detectLanguage
sentence only if verified on-device first; otherwise drop it or mark it
explicitly unverified.
