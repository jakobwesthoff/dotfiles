# Coding conventions

These guidelines apply globally across all my projects. Project-
specific CLAUDE.md files may extend or override these where appropriate.

When in doubt about a design decision, ask rather than assume.

## Agent model selection

When spawning Explore Task agents, prefer Haiku or Sonnet models to
minimize cost and latency. Opus is allowed when genuinely needed for
higher-quality results, but ask for my confirmation first.

When spawning Plan Task agents, always use the primary model (the same
model the parent conversation is using). Plan agents require the same
level of reasoning as the main conversation — downgrading them
produces lower-quality architectural plans.

When spawning Task agents for git commits (or any task that primarily
runs shell commands rather than requiring deep reasoning), always
explicitly set `model: "sonnet"`. The Bash subagent type inherits the
parent model when no model is specified, which wastes Opus tokens on
mechanical work.

## General best practices

Run shell scripts through `shellcheck`.

### ULID generation

Use `mkulid -l` to generate lowercase ULIDs. Use `-n <count>` to
generate multiple at once. Useful when creating documents in a
directory that need a random but chronologically sortable prefix
(e.g., todo files like `<ulid>-short-description.md`).

### SESSION.md

While working, if you come across any bugs, missing features, or other
oddities about the implementation, structure, or workflow, **add a
concise description of them to SESSION.md** to defer solving such
incidental tasks until later. You do not need to fix them all straight
away unless they block your progress; writing them down is often
sufficient. **Do not write your accomplishments into this file.**

## Rust guidelines

- When adding dependencies to Rust projects, use `cargo add`.
- In code that uses `anyhow` or `eyre` `Result`s, consistently use
  `.context()` prior to every error-propagation with `?`. Context
  messages in `context` should be simple present tense, such as to
  complete the sentence "while attempting to ...".
- Prefer `expect()` over `unwrap()`. The `expect` message should be very
  concise, and should explain why that expect call cannot fail.
- When designing pub or crate-wide Rust APIs, consult the checklist in
  <https://rust-lang.github.io/api-guidelines/checklist.html>.

### Writing compile_fail Tests

Use `compile_fail` doctests to verify when certain code should _not_
compile, such as for type-state patterns or trait-based enforcement.
Each `compile_fail` test should target a specific error condition since
the doctest only has a binary output of whether it fails to compile, not
the many reasons _why_. Make sure you clearly explain exactly WHY the
code should fail to compile.

If there is no obvious item to add the doctest to, create a new private
item with `#[allow(dead_code)]` that you add the compile-fail tests to.
Document that that's its purpose.

Before committing, create a temporary example file for each compile-fail
test and check the output of `cargo run --example <name>` to ensure it
fails for the correct reason. Remove the temporary example after.

## Git workflow

Delegate all committing to a Sonnet subagent (`model: "sonnet"`). Use
`git mv` for tracked files. All commits — whether made by a subagent or
directly — must follow the rules below.

### Commit subagent instruction template

When spawning a commit subagent, pass the following instruction block
verbatim (substituting only the `{placeholders}`):

```
{commit instructions here — files to stage, title, etc.}

Commit rules (follow exactly):
- Atomic commits grouped by semantic feature, each self-contained and buildable.
- Write the message to .tmp-commit-msg, commit with `git commit -F .tmp-commit-msg`, remove the file after.
- Title: concise present-tense, no semantic prefixes (feat:, fix:, etc.).
- Title-only when the title is self-explanatory. Only add a body for
  caveats, limitations, or non-obvious trade-offs not captured elsewhere.
  Never summarize, reiterate, or explain file contents — the diff and
  the files themselves serve that purpose. Don't mention tooling side effects.
- If a body is needed: wrap prose to git conventions, use backticks for
  inline types/snippets, indented blocks for multi-line code.
- Never mention AI, Claude, or Anthropic. Never add Co-Authored-By or similar.
```

## Documentation preferences

### Documentation examples

- Use realistic names for types and variables.

## Code style preferences

Document when you have intentionally omitted code that the reader might
otherwise expect to be present.

Add TODO comments for features or nuances that were deemed not important
to add, support, or implement right away.

### Literate Programming

Apply literate programming principles to make code self-documenting and maintainable across all languages:

#### Core Principles

1. **Explain the Why, Not Just the What**: Focus on business logic, design decisions, and reasoning rather than describing what the code does at a mechanical level.
2. **Top-Down Narrative Flow**: Structure code to read like a story with clear sections that build logically:
   ```rust
   // =========================================================
   // Plugin Configuration Extraction
   // =========================================================

   // First, we extract plugin metadata from Cargo.toml to determine
   // what files we need to build and where to put them.
   ```
   ...
3. **Inline Context**: Place explanatory comments immediately before relevant code blocks, explaining the purpose and any important context:
   ```python
   # Convert timestamps to UTC for consistent comparison across time zones.
   # This prevents edge cases where local time changes affect rebuild detection.
   utc_timestamp = datetime.utcfromtimestamp(file_stat.st_mtime)
   ```
4. **Avoid Over-Abstraction**: Prefer clear, well-documented inline code over excessive function decomposition.
5. **Self-Contained When Practical**: Reduce dependencies on external shared utilities when the logic is simple enough to be self-contained.

#### Implementation Benefits

- **Maintainability**: Future developers can quickly understand both implementation and design rationale
- **Debugging**: When code fails, documentation helps identify which logical step failed and why
- **Knowledge Transfer**: Code serves as documentation of the problem domain, not just the solution
- **Reduced Cognitive Load**: Readers don't need to mentally reconstruct the author's reasoning

#### When to Apply

Use literate programming for:
- Complex algorithms with multiple phases or decision points
- Code implementing business logic rather than simple plumbing
- Code where the "why" is not immediately obvious from the "what"
- Integration points between systems where context matters

Avoid over-documenting:
- Simple utility functions where intent is clear from the signature
- Trivial getters/setters or obvious wrapper code
- Code that's primarily syntactic sugar over well-known patterns

# Common failure modes when helping

## The XY Problem

The XY problem occurs when someone asks about their attempted solution (Y) instead of their actual underlying problem (X).

### The Pattern
1. User wants to accomplish goal X
2. User thinks Y is the best approach to solve X
3. User asks specifically about Y, not X
4. Helper becomes confused by the odd/narrow request
5. Time is wasted on suboptimal solutions

### Warning Signs to Watch For
- Focus on a specific technical method without explaining why
- Resistance to providing broader context when asked
- Rejecting alternative approaches outright
- Questions that seem oddly narrow or convoluted
- "How do I get the last 3 characters of a filename?" (when they want file extension)

### How to Avoid It (As Helper)
- **Ask probing questions**: "What are you trying to accomplish overall?"
- **Request context**: "Can you explain the bigger picture?"
- **Challenge assumptions**: "Why do you think this approach will work?"
- **Offer alternatives**: "Have you considered...?"

### Red Flags in User Requests
- Very specific technical questions without motivation
- Unusual or roundabout approaches to common problems
- Dismissal of "why do you want to do that?" questions
- Focus on implementation details before problem definition

### Best Response Pattern
1. Acknowledge the specific question asked
2. Ask about the underlying goal before diving into implementation
3. If the goal differs from the approach, explain the trade-offs
4. Offer a solution to the actual problem (X), not just the asked question (Y)

## Premature Implementation

Do not jump straight to writing code. First, make sure you understand
the problem fully. Read existing code and tests before proposing
changes. Ask clarifying questions when the requirements are ambiguous
rather than making assumptions.

If a change touches code you haven't read, read it first. Understand
the surrounding context, conventions, and constraints before suggesting
modifications.
