# Missing official content guidelines: consistent terminology, no time-sensitive info, default-with-escape-hatch

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/writing-principles.md` (no counterpart sections); `references/creation-workflow.md` Phase 5 Content Checks (no corresponding checks)

## Current state

The writing guide covers prescriptive style, code-first, anti-patterns, cross-references, descriptions, templates, and QA. Three content guidelines from the official best-practices doc are absent.

## Problem / opportunity

All three are concrete, checkable rules from https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices (fetched 2026-07-04) that apply directly to project skills this meta-skill generates:

1. **Consistent terminology**: "Choose one term and use it throughout the Skill." The doc's bad example mixes "API endpoint / URL / API route / path" and "field / box / element / control". Project skills extracting codebase patterns are especially prone to this because different source files use different vocabulary.
2. **Avoid time-sensitive information**: don't write content that expires ("If you're doing this before August 2025, use the old API"). Where legacy behavior must be documented, the doc's pattern is a collapsed "Old patterns" section (`<details>` block) describing the deprecated form, keeping the main content current-only. Relevant for skills near migrations, an explicit Phase 2 concern (the workflow already extracts "anti-patterns present in the codebase").
3. **Avoid offering too many options / provide a default**: "Don't present multiple approaches unless necessary"; give one default plus an escape hatch ("Use pdfplumber... For scanned PDFs requiring OCR, use pdf2image with pytesseract instead"). This sharpens the existing "Decision trees" bullet in "What Distinguishes a Good Skill": a decision tree is for genuinely context-dependent choices; when one approach dominates, name a single default instead.

## Proposed change

Add the three guidelines to writing-principles.md (each is a short paragraph plus the official example pattern) and mirror them as Phase 5 content checks: terminology consistent; no expiring statements outside an old-patterns section; one default per task with escape hatches rather than option lists.
