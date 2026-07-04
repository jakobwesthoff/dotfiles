# Imprint config: no instructions for generating the encrypted contact values

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/config.md` — "Imprint (Optional)" section

**Current state**: The section shows placeholder values
(`email_encrypted: "encrypted-string"`, `phone_encrypted:
"encrypted-string"`, `encryption_key: "your-key"`) and says only
"Contact details are encrypted to prevent scraping." There is no
explanation of the scheme or how to produce valid values.

**Problem**: An agent or user enabling the imprint hits a dead end: the
skill gives no way to generate values the imprint page can actually
decrypt. Wrong values fail silently (the page renders, but the contact
spans decode to garbage), since decryption happens client-side with no
validation.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `templates/imprint.njk` (decryption side): the page embeds
  `encryption_key` from config, applies ROT13 to it, base64-decodes each
  `*_encrypted` value, and XORs it bytewise with the ROT13'd key
  (script at the bottom of imprint.njk, lines 156-181). A `<noscript>`
  fallback notes JavaScript is required to display contact info.
- `GUIDE.md` "Contact encryption" section (encryption side) provides the
  matching Node.js snippet: `encrypt(text, key)` XORs `text` with
  `rot13(key)` and base64-encodes the result via `btoa`; the **plain**
  key (not ROT13'd) goes into `config.yaml` as `encryption_key`, and the
  script outputs go into `email_encrypted` / `phone_encrypted`.
- Caveat found during verification: the repo's `AGENTS.md` labels the
  field `encryption_key: "rot13-encoded-key"`, which contradicts
  GUIDE.md + imprint.njk (storing a ROT13'd key would make decryption XOR
  with the original key while encryption used the ROT13'd key, producing
  garbage). GUIDE.md and imprint.njk are the consistent pair; follow
  those.

**Proposed change**: In config.md's imprint section, document the scheme
in one or two sentences (XOR with ROT13 of the key, base64-encoded;
decrypted client-side; noscript users see a JS-required notice) and
either inline the generation snippet from GUIDE.md's "Contact
encryption" section or state precisely that the snippet there must be
used, with the plain key stored as `encryption_key`.
