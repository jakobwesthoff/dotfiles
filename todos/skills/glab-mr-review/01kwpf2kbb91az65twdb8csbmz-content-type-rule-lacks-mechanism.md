# Content-Type rule is stated without its mechanism; the "HTTP 415" figure is empirical, not documented

**Skill**: glab-mr-review
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/SKILL.md`, "Critical rules" (first bullet)
- `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, "Posting with glab api" (CRITICAL note)

## Current state

> **CRITICAL:** The `-H 'Content-Type: application/json'` header is REQUIRED
> when using `--input`. Without it, the API returns HTTP 415 Unsupported
> Media Type.

The rule is repeated in both files as a bare imperative with no explanation
of why glab, a GitLab-native CLI, would omit the header itself.

## Problem / opportunity

The rule is correct, and its mechanism is verifiable: glab genuinely sends
no Content-Type for `--input` bodies. Recording the mechanism in the skill
turns a cargo-cult rule into checkable knowledge (and makes it obvious when
the rule can be retired: the day glab starts defaulting the header). The
415 status itself does not appear in GitLab's documented REST status codes,
so it should be kept as an observed symptom, not presented as documented
API behavior.

## Grounding

- glab source, `internal/commands/api/api.go` on `main`
  (https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/api/api.go,
  fetched 2026-07-04): when `--input` is used, the file is set as the
  request body and only a Content-Length header is added:

  ```go
  requestBody = file
  if size >= 0 {
      requestHeaders = append([]string{fmt.Sprintf("Content-Length: %d", size)},
          requestHeaders...)
  }
  ```

  No default Content-Type is applied; user headers from `-H` are appended
  as-is.
- GitLab REST troubleshooting status-code reference
  (https://docs.gitlab.com/api/rest/troubleshooting/, fetched 2026-07-04)
  does not list 415 among documented status codes.

## Proposed change

Keep the rule, add one sentence of mechanism in gitlab-api-comments.md:
"`glab api --input` sends the file as a raw body with only a Content-Length
header (no Content-Type), so the JSON content type must be supplied
explicitly with `-H`." Optionally rephrase "the API returns HTTP 415" to
"the request fails (observed: HTTP 415 Unsupported Media Type)".
