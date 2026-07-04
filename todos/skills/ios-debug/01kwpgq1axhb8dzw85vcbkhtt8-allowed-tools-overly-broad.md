# `allowed-tools` grants are broader than the documented workflow needs (`sudo`, bare `timeout`, bare `uv run`)

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, frontmatter line 7

**Current state**:

```yaml
allowed-tools: Bash(pymobiledevice3 *), Bash(sudo pymobiledevice3 *), Bash(uv run *), Bash(timeout *), Read
```

**Problem**: `allowed-tools` pre-approves these patterns without a permission prompt whenever the skill is active. Three grants exceed what the skill's own instructions use:

1. `Bash(sudo pymobiledevice3 *)` — the skill explicitly delegates the only sudo operation to the user: "Started a tunnel **in a separate terminal**" and "Remind the user to start it". No instruction in the body has Claude run sudo itself, so this rule silently authorizes privileged commands the documented workflow never issues. (If the intent is for Claude to start tunnels itself, the body should say so; then the grant is justified — but note sudo will still block on the password prompt in a non-interactive shell.)
2. `Bash(timeout *)` — prefix-matches *any* command wrapped in `timeout`, e.g. `timeout 5 rm -rf ~`. It is effectively a blanket Bash allowlist while the skill is active.
3. `Bash(uv run *)` — pre-approves arbitrary code execution (any Python via heredoc). Unlike the first two this one is genuinely required by the documented workflow (the automation snippet), so it is a conscious trade-off; it should just be a deliberate one.

**Grounding**:
- Claude Code skills documentation (https://code.claude.com/docs/en/skills), "Pre-approve tools for a skill": "The `allowed-tools` field grants permission for the listed tools while the skill is active, so Claude can use them without prompting you for approval. It does not restrict which tools are available." And: "Review project skills before trusting a repository, since a skill can grant itself broad tool access."
- Skill body: prerequisites item 4 and the `InvalidServiceError` paragraph put tunnel-starting on the user; no body instruction runs `sudo`.
- Permission rule syntax (same docs, permission rules examples such as `Bash(git add *)`): prefix matching, so `Bash(timeout *)` matches any argv beginning `timeout `.

**Proposed change**:
- Drop `Bash(sudo pymobiledevice3 *)` (workflow never uses it), or move tunnel-starting into the skill body deliberately and document the password-prompt limitation.
- Drop `Bash(timeout *)`. If run-away protection for the heredoc is still wanted, enforce the deadline inside the script (`asyncio.wait_for(...)` around the whole `run()` coroutine) instead of an outer `timeout` wrapper, which also removes the GNU-coreutils dependency (see the separate `timeout`-availability todo).
- Keep `Bash(pymobiledevice3 *)`, `Bash(uv run *)`, `Read` as the minimal working set.
