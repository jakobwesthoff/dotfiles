# Enable fullscreen mode
# https://code.claude.com/docs/en/fullscreen
export CLAUDE_CODE_NO_FLICKER=1

# Force-enable the greyed-out next-prompt suggestion in the input field.
# The feature sits behind a server-side rollout flag that defaults to off;
# this env var is checked before that flag and overrides it. The
# `promptSuggestionEnabled` setting cannot do this, as it is only consulted
# once the rollout flag has already passed.
export CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=1

# Enable Todo/Task Tracking, as it is disabled now by default in Opus 4.8,
# Sonnet 5, Fable 5, Mythos 5 and later
export CLAUDE_CODE_ENABLE_TODO_TOOLS=1
