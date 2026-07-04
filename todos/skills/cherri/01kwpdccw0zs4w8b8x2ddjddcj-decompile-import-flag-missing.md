# CLI coverage gap: `--import=` (decompile an existing Shortcut to Cherri) is not mentioned

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/patterns-and-practices.md`, section "CLI usage" (also relevant to SKILL.md "Invoking the compiler")

**Current state**: The CLI usage table covers compile, signing variants,
`--debug`, `--open`, `--comments`, `--share=anyone`. It does not mention
`--import=`.

**Problem**: A realistic task — "I have this existing Shortcut (or an
iCloud share link); give me the Cherri source" — is directly supported by
the compiler but invisible to an agent using this skill. The agent would
likely hand-transcribe the shortcut instead.

**Grounding**: `cherri --help` (Cherri Compiler v2.1.0, 2026-07-04):

```
--import=  [BETA] Import Shortcut from an iCloud link or file path and convert to Cherri.
```

Related flags in the same help output that gate decompilation quality:
`--toolkit=` (path to Shortcuts ToolKit SQLite database) and
`--no-toolkit` ("Do not use the Shortcuts toolkit DB to decompile
non-standard actions."). Upstream v2.2.0 release notes list decompilation
improvements ("we now demarshal data from the Shortcut using the plist
package instead of JSON") and v2.2.0's "What's Next" names "Refining
decompilation out of beta" — i.e. the feature is beta on all current
versions.

Official docs (https://cherrilang.org/decompilation.html, via search
2026-07-04): `--import=` takes an iCloud link or a local **unsigned**
Shortcut file path; "the import feature works best with an iCloud link,
as decompiling signed Shortcut files is not supported for the time
being."

**Proposed change**: Add a line to the CLI usage table:
`cherri --import=<icloud-link-or-file>  # [BETA] convert an existing Shortcut to Cherri source`,
with two caveats: the feature is beta (review and test-compile the
output), and local `.shortcut` files must be unsigned — signed files need
an iCloud link instead. Optionally note `--no-toolkit` for machines
without a Shortcuts toolkit DB.
