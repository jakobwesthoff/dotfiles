# pymobiledevice3 is not installed on this machine; skill gives no check step and ignores the no-install `uvx` path

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Prerequisites" ("pymobiledevice3 must be installed (`uv tool install pymobiledevice3`).")

**Current state**: The prerequisite is stated as a fact about the environment, with no instruction to verify it or to recover when it is absent. All CLI examples assume `pymobiledevice3` on PATH.

**Problem**: On the machine this dotfiles repo configures, the prerequisite does not currently hold: `uv tool list` (2026-07-04) shows no pymobiledevice3, and `pymobiledevice3` is not on PATH (`command not found`). An agent following the skill hits "command not found" at step 1 with no guidance. Two grounded remedies exist:

1. Add an explicit check/install step: run `pymobiledevice3 version`; on failure run `uv tool install pymobiledevice3` (requires-python is `>=3.9` per the 9.33.0 `pyproject.toml:5`, so any current uv-managed Python works).
2. Or drop the global-install requirement for CLI calls by using `uvx pymobiledevice3 ...`: per the uv documentation (https://docs.astral.sh/uv/guides/tools/), "The `uvx` command invokes a tool without installing it" (alias for `uv tool run`), executing it in a temporary isolated environment. This matches the skill's Python snippet, which already avoids a global install via `uv run --with pymobiledevice3`. If adopted, the frontmatter `allowed-tools` needs `Bash(uvx pymobiledevice3 *)` instead of/alongside `Bash(pymobiledevice3 *)`, and the tunnel commands become `sudo uvx pymobiledevice3 ...`.

One consistency consideration for option 2: `uvx` and `uv run --with` resolve the latest release independently of any globally installed version, which keeps CLI and Python paths on the same (current) version — but also means upstream API churn hits immediately (see the connect-timeout todo for a concrete instance; that todo discusses pinning).

**Grounding**:
- Local state: `uv tool list` output contains huggingface-hub, mflux, platformio only; `which pymobiledevice3` → not found (both captured 2026-07-04).
- `requires-python = ">=3.9"`: pymobiledevice3 9.33.0 sdist `pyproject.toml:5`.
- uvx semantics: https://docs.astral.sh/uv/guides/tools/ as quoted above.
- Anthropic skill best practices (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), "Avoid assuming tools are installed": bad example "Use the pdf library to process the file", good example shows the explicit install command first.

**Proposed change**: Add a first step "verify the tool" (`pymobiledevice3 version`, fall back to `uv tool install pymobiledevice3`), or switch the skill to `uvx pymobiledevice3` invocations throughout and update `allowed-tools` accordingly. Either way, decide and document the version-pinning stance together with the connect-timeout todo.
