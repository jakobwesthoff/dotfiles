# Demo section: frameless video variant and VHS recording guidance missing

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/sections.md` — "demo.html (Optional)" section

**Current state**: The skill documents only the macOS-window-framed demo
variant and says videos go in `docs/pages/assets/` with `.webm` primary
and `.mp4` Safari fallback. Nothing on a frameless variant or on how to
produce the video.

**Problem / opportunity**: Two grounded gaps:

1. The template supports a frameless demo (video directly in the
   container with class `demo-video`), which fits GUI apps or
   screencasts where a fake terminal frame is wrong.
2. For CLI projects, the starter repo ships a ready-made VHS setup for
   recording a matching demo video; the skill leaves "where does
   demo.webm come from" unanswered.

**Grounding**: `jakobwesthoff/project-page-starter` local clone at
origin HEAD (commit e9be969):

- `GUIDE.md` "sections/demo.html (optional)" shows the "Without the
  frame" variant:

  ```html
  <video autoplay loop muted playsinline class="demo-video">
  ```

  `.demo-video` is defined in `templates/styles/components.css`.
- `GUIDE.md` "Recording a Demo Video with VHS": the repo's `vhs/`
  directory contains a pre-configured tape (`vhs/demo.tape`, exists in
  the clone) with a theme matching the landing page colors; recording is
  `cd vhs && vhs demo.tape` then copying `demo.webm`/`demo.mp4` into
  `docs/pages/assets/`. Requirements per the guide: `vhs`, `ttyd`,
  `ffmpeg` (all brew-installable). The tape records at 2x resolution for
  HiDPI (1800x800 for a 900x400 display size), and the guide maps CSS
  variables to VHS theme keys (`--color-bg` → `background`,
  `--color-text` → `foreground`, `--color-primary` → `magenta`).

**Proposed change**: In sections.md's demo section, add (a) the
frameless variant markup using `.demo-video`, with a sentence on when to
prefer it, and (b) a short "Producing the video" note pointing at the
starter repo's `vhs/demo.tape` workflow, its 2x-resolution convention,
and the vhs/ttyd/ffmpeg prerequisites.
