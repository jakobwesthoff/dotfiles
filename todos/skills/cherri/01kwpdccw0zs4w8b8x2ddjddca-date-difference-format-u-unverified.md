# Date-difference pattern relies on unverified custom date format "U"; a verifiable alternative exists

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/common-patterns.md`, section "Date difference (days between two dates)"

**Current state**:

> There is no `getTimeBetweenDates` action. Use Unix epoch seconds via
> custom date formatting to calculate differences:
> ```ruby
> const eventSec = formatDate(eventDate, "Custom", "U")
> ```

**Problem**: The pattern compiles (verified: `formatDate(text date,
dateFormats ?dateFormat = "Short", text ?customDateFormat)` accepts
`"Custom", "U"`), but the load-bearing claim — that custom format `"U"`
yields Unix epoch seconds at runtime — has no supporting source:

- Shortcuts' custom date formats use ICU/TR35 pattern symbols, where `U`
  means "cyclic year name", not epoch seconds.
- Apple's own guide for Unix-time handling in Shortcuts
  (https://support.apple.com/guide/shortcuts/format-date-timestamps-apdfb33b0e17/ios)
  and Matthew Cassinelli's write-ups document the epoch workflow via the
  **Get Time Between Dates** action against a `1970-01-01T00:00:00Z` date,
  not via a format string.
- No `"U"` format or unix/epoch handling appears anywhere in the cherri
  compiler repo (grep over `*.go` and `*.cherri` in
  /Users/jakob/Development/github/electrikmilk/cherri).

If `"U"` does not produce epoch seconds on-device, the whole pattern
silently computes garbage.

**Grounding for the alternative**: "There is no getTimeBetweenDates
action" is correct as far as built-ins go (verified: `cherri
--action=time --no-ansi` and `--action=between` find no such action,
v2.1.0). But the underlying Shortcuts action exists and can be bound via
the skill's own custom-action mechanism. Identifier and parameters
confirmed by ScPL action docs
(https://docs.scpl.dev/actions/gettimebetweendates):

- Identifier: `is.workflow.actions.gettimebetweendates`
- Input: date (action input, `WFInput` semantics via passed date)
- `WFTimeUntilReferenceDate`: "Right Now" (default) | "Other"
- `WFTimeUntilCustomDate`: date string when reference is "Other"
- `WFTimeUntilUnit`: "Total Time", "Seconds", "Minutes", "Hours",
  "Days", "Weeks", "Months", "Years" (default "Minutes")
- Output: number (negative if input date is before the reference date)

**Proposed change**: Replace the format-"U" pattern with a custom action
definition for `is.workflow.actions.gettimebetweendates` (units enum +
reference-date parameters as above) and compute day differences directly
in "Days" units. Before landing, verify the produced action on-device
once (compile-time verification cannot confirm runtime output). If the
"U" trick is retained at all, it must first be verified by running a
compiled shortcut and observing the output; otherwise drop it.
