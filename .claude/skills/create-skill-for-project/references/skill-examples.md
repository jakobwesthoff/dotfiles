---
name: skill-examples
description: >-
  Concrete skill examples at each tier, plus good/bad frontmatter and description
  examples, and common anti-patterns to avoid.
metadata:
  tags: examples, tiers, anti-patterns, templates
---

## Tier 1 Example: testing-conventions

A single-file skill encoding a project's testing patterns.

```
testing-conventions/
└── SKILL.md
```

```yaml
---
name: testing-conventions
description: >-
  Write and organize Vitest unit tests following project conventions. Use when
  the user asks to "write tests", "add specs", or mentions "vitest".
---
```

```markdown
## When to use

Use this skill whenever writing or modifying tests in this project.

## Test File Location

Place test files next to the source file they test:

\`\`\`
src/
  utils/
    format-date.ts
    format-date.test.ts    # <-- here, not in a separate __tests__/ dir
\`\`\`

## Test Structure

\`\`\`ts
import { describe, it, expect } from 'vitest';
import { formatDate } from './format-date';

describe('formatDate', () => {
  it('formats ISO dates to human-readable', () => {
    expect(formatDate('2024-01-15')).toBe('January 15, 2024');
  });

  it('returns "Invalid date" for malformed input', () => {
    expect(formatDate('not-a-date')).toBe('Invalid date');
  });
});
\`\`\`

## Anti-Patterns

NEVER use `jest` imports — this project uses Vitest exclusively.

\`\`\`ts
// FORBIDDEN
import { jest } from '@jest/globals';

// CORRECT
import { vi } from 'vitest';
\`\`\`

NEVER place tests in a top-level `__tests__/` directory.
NEVER use `test()` — always use `it()` inside a `describe()` block.
```

**Total: ~50 lines.** Single concept, fits comfortably in one file.

---

## Tier 2 Example: api-guide

A hub-and-spokes skill for a project's API patterns.

```
api-guide/
├── SKILL.md
└── references/
    ├── endpoint-patterns.md
    ├── error-handling.md
    └── authentication.md
```

**SKILL.md** (router):
```yaml
---
name: api-guide
description: >-
  Build REST API endpoints following project patterns. Use when creating new
  endpoints, handling errors, or implementing auth middleware.
---
```

```markdown
## When to use

Use this skill when creating or modifying API endpoints, error handling, or
authentication in the backend.

## Reference Files

- [references/endpoint-patterns.md](references/endpoint-patterns.md) — Route
  structure, request validation, response format
- [references/error-handling.md](references/error-handling.md) — Error types,
  HTTP status codes, error response shape
- [references/authentication.md](references/authentication.md) — JWT middleware,
  role-based access, token refresh flow
```

**references/endpoint-patterns.md** (one spoke):
```yaml
---
name: endpoint-patterns
description: Route structure, validation, and response format for REST endpoints
metadata:
  tags: api, routes, validation, response
---
```

```markdown
## Endpoint Structure

Every endpoint follows this pattern:

\`\`\`ts
import { Router } from 'express';
import { z } from 'zod';
import { validate } from '../middleware/validate';

const router = Router();

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
});

router.post('/users', validate(CreateUserSchema), async (req, res) => {
  const user = await userService.create(req.validated);
  res.status(201).json({ data: user });
});

export default router;
\`\`\`

NEVER return raw database objects. Always map to a response DTO.
NEVER use `any` for request bodies — always define a Zod schema.

For error responses, see [references/error-handling.md](references/error-handling.md).
```

**Total: ~70 lines for SKILL.md + ~80 lines per reference file.** Multiple distinct
topics, each in its own file.

---

## Tier 3 Example: component-library

A hub-and-spokes skill with code assets for complex UI components.

```
component-library/
├── SKILL.md
├── references/
│   ├── form-components.md
│   └── data-display.md
└── assets/
    ├── form-select.tsx
    └── data-table.tsx
```

**references/form-components.md** links to the asset:
```markdown
For a complete Select component implementation, see
[assets/form-select.tsx](../assets/form-select.tsx).
```

The asset file (`assets/form-select.tsx`) is a complete, runnable component —
not a fragment. It compiles as part of the project's build pipeline.

**Use Tier 3 when:** code examples exceed ~40 lines and must be complete,
runnable files rather than inline snippets.

---

## Good vs Bad Frontmatter

**Good:**
```yaml
---
name: deploy-workflow
description: >-
  Deploy services to staging and production using the project's CI pipeline.
  Use when the user mentions "deploy", "release", "staging", or "production".
---
```

**Bad — name doesn't match directory:**
```yaml
---
name: deployment    # Directory is deploy-workflow/ — MUST match
description: Deploys stuff.
---
```

**Bad — description is vague:**
```yaml
---
name: deploy-workflow
description: Helps with deployment.  # No triggers, no specifics
---
```

---

## Good vs Bad Descriptions

**Good — WHAT + WHEN with trigger keywords:**
```yaml
description: >-
  Generate TypeScript API clients from OpenAPI specs. Use when the user wants
  to "generate a client", "create API types", or mentions "OpenAPI" or "swagger".
```

**Bad — only WHAT, no WHEN:**
```yaml
description: Generates API clients.
```

**Bad — only WHEN, no WHAT:**
```yaml
description: Use when working with APIs.
```

**Bad — too long (wastes tokens on every interaction):**
```yaml
description: >-
  This skill helps you generate TypeScript API clients from OpenAPI specifications.
  It supports OpenAPI 3.0 and 3.1, handles complex nested types, generates both
  request and response types, creates fetch-based client functions with proper
  error handling, and can also generate React Query hooks for each endpoint.
  Use this whenever you need to interact with a REST API that has an OpenAPI spec.
```

---

## Anti-Pattern Examples

### The Monolith
A single SKILL.md with 800+ lines covering authentication, authorization, API
patterns, database queries, and deployment. The agent loads ALL of it even when
the user just wants to add a simple endpoint.

**Fix:** Split into Tier 2 with focused reference files.

### The Empty Router
```markdown
## Reference Files
- [references/a.md](references/a.md)
- [references/b.md](references/b.md)
- [references/c.md](references/c.md)
```
No orientation, no "when to use", no context. The agent doesn't know which file
to load without reading all of them.

**Fix:** Add a "When to use" section and one-line descriptions for each link.

### Generic Content
```markdown
## Error Handling

Use try-catch blocks to handle errors:
\`\`\`ts
try {
  doSomething();
} catch (error) {
  console.error(error);
}
\`\`\`
```
This is textbook TypeScript, not project-specific guidance. The AI already knows
this from its training data.

**Fix:** Show the project's actual error handling pattern with its real error
types, logging utilities, and response format.
