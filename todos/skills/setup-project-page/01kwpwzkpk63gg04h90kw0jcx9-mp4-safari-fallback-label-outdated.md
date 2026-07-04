# ".mp4 (Safari fallback)" label is outdated for current Safari

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/sections.md` — "demo.html (Optional)", "Video sources" note

**Current state**: "Always provide both `.webm` (primary) and `.mp4`
(Safari fallback). Videos go in `docs/pages/assets/`."

**Problem**: Current Safari plays WebM `<video>` natively, so "Safari
fallback" misstates who the `.mp4` is for. The dual-source advice
itself remains correct: the fallback covers *older* Safari, which is
still a real population (every iPhone that cannot update past iOS 17.3,
and Macs on pre-Big Sur Safari). An agent reasoning from the current
label could wrongly conclude the `.mp4` is unnecessary once it sees
Safari listed as supporting WebM.

**Grounding**: caniuse WebM feature data
(raw.githubusercontent.com/Fyrd/caniuse/main/features-json/webm.json,
fetched 2026-07-04):

- Desktop Safari: full support from 16.0; caniuse note 7: "Safari
  14.1 – 15.6 has full support of WebM, but requires macOS 11.3 Big Sur
  or later." Earlier versions are marked partial with notes limited to
  VP8/VP9 in WebRTC, i.e. no WebM file playback in `<video>`.
- iOS Safari: full support from 17.4 (released March 2024); before
  that, partial support is WebRTC-only, so `<video src=*.webm>` does
  not play.
- Latest listed versions at fetch time: Safari 27.0 (TP), iOS Safari
  26.5 — both full support.
- caniuse note 8 applies to all supporting versions: "Does not support
  alpha transparency" (irrelevant to opaque demo recordings).

The template repo carries the same label: `GUIDE.md` project-structure
listing annotates `demo.mp4` with "Safari fallback (optional)".

**Proposed change**: Keep the dual-source instruction, fix the label:
"`.mp4` fallback for older Safari (iOS before 17.4, macOS Safari before
14.1/Big Sur)" or simply "(fallback for older browsers)". Since the
same wording lives in the template repo's GUIDE.md and skill copy, the
fix belongs in both once a sync direction is chosen (see the existing
skill-copy-drift todo).
