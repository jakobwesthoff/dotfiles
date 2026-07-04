# "Repeated detail-getter crash" quirk is wrong: no crash, and the prescribed workaround is over-specified

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md`, section "Avoid calling the same detail-getter multiple times in one expression"

**Current state**:

> Calling actions like `getWeatherDetail()` multiple times on the same
> source variable can crash the compiler. Workaround: interleave each
> call with a variable append:
> ```ruby
> // WRONG — may crash
> @msg = "Temp: {getWeatherDetail(@weather, "Temperature")} Wind: {getWeatherDetail(@weather, "Wind Speed")}"
> ...
> ```

The first-pass review could not reproduce the crash.

**Problem**: The entry misdiagnoses the failure and prescribes an
unnecessary code shape.

1. The "WRONG" example does not crash. It fails with a clean parser
   error, and the cause is not repetition: action calls are not allowed
   inside string interpolation at all (inline `{...}` accepts only
   variable/constant/global references). One inline action call fails
   the same way as two.
2. Calling the same detail-getter multiple times on the same source
   variable is fine when each result is stored in a variable. The
   "interleave each call with a variable append" workaround is not
   needed; plain sequential assignments compile.

**Grounding** (Cherri Compiler v2.1.0, commit 2ca7dfe, test compiles
with `--skip-sign --no-ansi`, 2026-07-04):

- The skill's WRONG example (with `@weather = getCurrentWeather()` and
  `#include 'actions/location'`) fails with
  `Error: Value of type 'text' not allowed in expression` — exit 1, no
  panic.
- Single inline action call, no repetition:
  `@msg = "Battery: {getBatteryLevel()}"` fails with
  `Error: Undefined inline reference 'getBatteryLevel()'`.
- Sequential calls without interleaving compile (exit 0):

  ```ruby
  @temp = getWeatherDetail(@weather, "Temperature")
  @wind = getWeatherDetail(@weather, "Wind Speed")
  @msg = "Temp: {@temp} Wind: {@wind}"
  ```

- The skill's interleaved "CORRECT" variant also compiles (exit 0), so
  the fix itself is harmless, just presented as load-bearing when it
  is not.
- No upstream record: GitHub issue searches for "weather", "detail",
  and "detectLanguage" in electrikmilk/cherri (2026-07-04) surface no
  issue about repeated detail-getter calls.

**Proposed change**: Delete this quirk entry. Its true content is
already covered by the "Expressions cannot contain action calls" entry;
extend that entry with the string-interpolation case and its exact
error (`Undefined inline reference '<call>'`): inline `{...}` in strings
accepts only variable/constant/global references, never action calls —
store the action result in a variable first.
