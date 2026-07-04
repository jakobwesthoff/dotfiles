# HTTP section omits `formRequest` and `fileRequest` (form-encoded and file-upload requests)

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "HTTP requests"

**Current state**: The HTTP section covers only `jsonRequest()` ("JSON
POST (most common for APIs)") and `downloadURL()` for GET. Sending
form-encoded bodies or uploading a file is not addressed.

**Problem**: A user whose API expects `application/x-www-form-urlencoded`
or a file upload has no path from this skill; an agent would likely
force everything through `jsonRequest` and fail at the API level.

**Grounding**: The compiler's bundled `actions/web.cherri` (source
checkout `/Users/jakob/Development/github/electrikmilk/cherri`,
v2.1.0-era main) defines all three request variants over the same
`downloadurl` identifier, differing in `WFHTTPBodyType`:

```
action 'downloadurl' formRequest(text url: 'WFURL', HTTPMethod ?method: 'WFHTTPMethod',
    dictionary! ?body: 'WFFormValues', dictionary! ?headers: 'WFHTTPHeaders') { "WFHTTPBodyType": "Form" }
action 'downloadurl' jsonRequest(...) { "WFHTTPBodyType": "JSON" }
action 'downloadurl' fileRequest(..., dictionary! ?body: 'WFRequestVariable', ...) { "WFHTTPBodyType": "File" }
```

(web.cherri lines 115-143.) The same `dictionary!` literal-only
restriction applies to their `body`/`headers` (see the jsonRequest todo).

Both are exposed by the installed compiler (verified 2026-07-04):
`cherri --action=formRequest --no-ansi` and `--action=fileRequest
--no-ansi` print `formRequest(text url, HTTPMethod ?method, dictionary
?body, dictionary ?headers)` and the equivalent `fileRequest(...)`
signature, with the HTTPMethod enum (POST, PUT, PATCH, DELETE).

**Proposed change**: Add one or two lines to the HTTP section naming
`formRequest(url, method, body, headers)` for form-encoded bodies and
`fileRequest(...)` for file bodies, with the same inline-literal
restriction on `body`/`headers`.
