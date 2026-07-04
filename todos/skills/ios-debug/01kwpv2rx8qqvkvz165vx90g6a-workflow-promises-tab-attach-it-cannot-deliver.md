# Workflow design: skill promises debugging the user's open tab, but its only working path cannot attach to one

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, frontmatter `description`, "Debugging workflow" section ordering, and "Prerequisites" items 2-3.

**Current state**: The description offers to "inspect, debug, or interact with Safari tabs on an iPhone or iPad". The workflow is ordered as: 1. discover open tabs ("Identify the tab the user wants to debug"), 2. execute JavaScript — where the only approach the skill itself permits (automation session; the inspector path is banned by its own Known Issues) "does NOT attach to an existing tab". Prerequisites require both device toggles (Web Inspector, Remote Automation) unconditionally.

**Problem**: Read end-to-end, the primary use case dissolves between step 1 and step 2:

1. Step 1's output ("identify the tab") feeds nothing. Step 2 re-navigates to a URL in an isolated automation context, so the only information step 1 contributes is the tab's URL — which the user can usually just state. The user's actual tab, with its logged-in session, scroll position, and app state, is never touched; per WebKit it *cannot* be from an automation session (see `01kwpv2rx8qqvkvz165vx90g67`: separate windows/storage, clean slate). The skill nowhere says plainly that "debug this tab" degrades to "load the same URL fresh, logged out".
2. The two prerequisites map one-to-one onto the two paths, but are presented as a single unconditional checklist: Web Inspector (item 2) gates the `opened-tabs`/inspector side (`WebInspectorNotEnabledError` from `connect()`, 9.33.0 sdist `services/webinspector.py:159` docstring); Remote Automation (item 3) gates `automation_session` (`RemoteAutomationNotEnabledError`, `services/webinspector.py:231` docstring). A user who only ever gets the automation flow is still told to flip both toggles, and the skill can't explain which toggle a given error points at (compounding the error-mapping gap in `01kwpgq1axhb8dzw85vcbkhtt5`).
3. The description's "interact with Safari tabs" is the trigger phrase most likely to attract exactly the request the body cannot fulfill (existing-tab interaction). This is the behavioral twin of the naming problem in `01kwph0psndj4zm9ba5f2k0ab7`, but survives any rename: it is in the description text and the workflow order.

**Grounding**: the skill's own text (lines quoted above; full read 2026-07-04); WebKit isolation statements as inlined in `01kwpv2rx8qqvkvz165vx90g67`; error-to-toggle mapping from the 9.33.0 sdist docstrings cited above.

**Proposed change**: Restructure the narrative around what the skill can actually deliver:

- Open with the capability statement: "Executes JavaScript against a fresh, isolated copy of a page in Safari on the device (plus whole-device screenshots). It cannot attach to or read the user's existing tab." Mirror that in the frontmatter description ("inspect, debug, or interact with Safari tabs" → "debug web pages by loading them in an isolated Safari automation session").
- Make the automation flow step 1. Demote tab discovery to an optional "find the URL if the user doesn't know it" step, and state what is lost versus the real tab (auth, storage, in-page state).
- Split the prerequisites by path: Remote Automation toggle for the main flow; Web Inspector toggle only when tab-listing is used. Tag each with the error name that appears when it is missing.
- For genuinely tab-bound questions (why is *my* session broken *here*), say what the honest fallbacks are: reproduce the state in the automation session (log in, set cookies — per run, see `01kwpv2rx8qqvkvz165vx90g67`), or hand off to desktop Safari's Develop-menu inspector, which does attach to the live tab but is manual.
