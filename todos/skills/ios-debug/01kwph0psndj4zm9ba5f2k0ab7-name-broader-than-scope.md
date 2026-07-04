# Skill name `ios-debug` promises general iOS debugging; the skill only covers Safari web debugging

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, frontmatter (`name`, `description`) and directory name `.claude/skills/ios-debug/`

**Current state**:

```yaml
name: ios-debug
description: >
  Debug websites and web apps running in Safari on a connected iOS device
  using pymobiledevice3. Use when the user wants to inspect, debug, or
  interact with Safari tabs on an iPhone or iPad.
```

The body covers exactly: Safari tab discovery, JS execution via WebKit automation, device screenshots.

**Problem**: The name claims a much larger domain (native app debugging, crash logs, syslog, lldb — none covered). Consequences: (a) a request like "debug my iOS app crash" plausibly triggers this skill via name-match and leads Claude down a Safari-only path; (b) humans and orchestrating agents misread the skill's purpose from the name alone (this audit's own task briefing assumed simctl/xcodebuild/crash-log content from the name). The description is good — third person, states what and when — but the name undermines it.

**Grounding**:
- Skill body: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md` contains only webinspector/automation/screenshot content (verified by full read; no simctl/xcodebuild/lldb/crash material).
- Anthropic skill best practices (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), "Naming conventions": avoid "Vague names" and "Overly generic" names; names should let you "Understand what a Skill does at a glance". Same page, description guidance: the name/description pair is what Claude uses "when deciding whether to trigger the Skill".
- Claude Code skills docs (https://code.claude.com/docs/en/skills), "How a skill gets its command name": for a skill under `.claude/skills/`, the command name comes from the **directory name**, so a rename means renaming the directory (frontmatter `name` alone only changes the display label).

**Proposed change**: Rename the directory to something scope-accurate, e.g. `.claude/skills/ios-safari-debug/` (command `/ios-safari-debug`), keeping frontmatter `name` in sync. Optionally sharpen the description's trigger vocabulary with terms users actually say for this workflow: "web inspector", "execute JavaScript on the page", "mobile Safari", "WKWebView" (only if WebView pages are genuinely reachable — see the opened-tabs semantics todo). Use `git mv` for the rename.
