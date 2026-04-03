#!/usr/bin/env bash
# Claude Code status line script
# Displays: [Model] │ [Directory] [Circle Bar] [%] [Tokens] [Rate Limit] [Cost]
#
# VERSION DETECTION:
#   Real-time mode  (Claude Code >= 2.1.72): context_window.used_percentage is present in JSON
#   Fallback mode   (Claude Code 2.0.27-2.1.71): parses transcript JSONL for last assistant message

# =========================================================
# ANSI color helpers
# =========================================================

DIM='\033[2m'
RESET='\033[0m'
GREEN='\033[32m'
YELLOW='\033[33m'
ORANGE='\033[38;5;208m'
RED='\033[31m'

# =========================================================
# Read and parse stdin JSON
# =========================================================

input=$(cat)

model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
used_pct_raw=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
rate_limit_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_limit_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# =========================================================
# Determine context usage percentage
# =========================================================

mode="UNKNOWN"
raw_used=0

if [ -n "$used_pct_raw" ]; then
    # Real-time mode: Claude Code >= 2.1.72 provides used_percentage directly
    raw_used=$(echo "$used_pct_raw" | awk '{printf "%.2f", $1}')
    mode="REALTIME"
elif [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Fallback mode: parse transcript JSONL for last assistant message with usage data.
    last_usage=$(grep -E '"type"\s*:\s*"assistant"' "$transcript_path" 2>/dev/null \
        | jq -s 'map(select(.message.usage.input_tokens != null))
                 | map(select((.message.usage.input_tokens + (.message.usage.cache_read_input_tokens // 0)) > 1000))
                 | last
                 | .message.usage' 2>/dev/null)

    if [ -n "$last_usage" ] && [ "$last_usage" != "null" ]; then
        input_toks=$(echo "$last_usage" | jq -r '.input_tokens // 0')
        cache_toks=$(echo "$last_usage" | jq -r '.cache_read_input_tokens // 0')
        total_toks=$((input_toks + cache_toks))
        raw_used=$(awk -v t="$total_toks" -v s="$context_window_size" 'BEGIN { printf "%.2f", (t / s) * 100 }')
        mode="FALLBACK"
    else
        raw_used=0
        mode="FALLBACK(no_data)"
    fi
else
    raw_used=0
    mode="UNKNOWN(no_transcript)"
fi

# =========================================================
# Compute absolute token counts
#
# Claude Code reserves a fixed-size autocompact buffer that is
# not exposed in the statusline JSON. The value below is derived
# from /context output (33k tokens, independent of window size).
# =========================================================

AUTOCOMPACT_BUFFER_TOKENS=33000

used_tokens=$(awk -v pct="$raw_used" -v size="$context_window_size" \
    'BEGIN { printf "%.0f", (pct / 100) * size }')
effective_tokens=$((context_window_size - AUTOCOMPACT_BUFFER_TOKENS))

# Usage percentage relative to effective (usable) capacity, capped at 100
used=$(awk -v u="$used_tokens" -v e="$effective_tokens" 'BEGIN {
    pct = (u / e) * 100
    if (pct > 100) pct = 100
    printf "%.0f", pct
}')

# =========================================================
# Debug log (written to stderr so it appears separately from status output)
# =========================================================

>&2 printf "[statusline] mode=%s used_tokens=%s effective_tokens=%s used=%s%%\n" \
    "$mode" "$used_tokens" "$effective_tokens" "$used"

# =========================================================
# Build circle progress bar (10 circles, ● filled / ○ empty)
# =========================================================

filled=$(echo "$used" | awk '{
    n = int($1 / 10)
    if (n > 10) n = 10
    print n
}')
empty=$((10 - filled))

# Choose color based on effective usage percentage
if   [ "$used" -ge 80 ]; then bar_color="$RED"
elif [ "$used" -ge 70 ]; then bar_color="$ORANGE"
elif [ "$used" -ge 60 ]; then bar_color="$YELLOW"
else                          bar_color="$GREEN"
fi

bar=""
for ((i=0; i<filled; i++)); do bar="${bar}●"; done
for ((i=0; i<empty;  i++)); do bar="${bar}○"; done

# =========================================================
# Compute human-readable token counts (used / effective capacity)
# =========================================================

format_tokens() {
    local tokens="$1"
    if [ "$tokens" -ge 1000000 ]; then
        awk -v t="$tokens" 'BEGIN { printf "%.1fM", t / 1000000 }'
    elif [ "$tokens" -ge 1000 ]; then
        awk -v t="$tokens" 'BEGIN { printf "%.0fk", t / 1000 }'
    else
        printf '%s' "$tokens"
    fi
}

token_display="$(format_tokens "$used_tokens") / $(format_tokens "$effective_tokens")"

# Yellow warning when token usage exceeds 262k
TOKEN_WARNING=262144
if [ "$used_tokens" -ge "$TOKEN_WARNING" ]; then
    token_color="${YELLOW}"
else
    token_color="${DIM}"
fi

# =========================================================
# Format session cost display
# =========================================================

cost_display=$(awk -v c="$session_cost" 'BEGIN {
    if (c < 0.01) printf "$%.3f", c
    else printf "$%.2f", c
}')

# =========================================================
# Build rate limit display (5-hour window)
#
# Shows a vertical block character (▁–█) mapping usage to 8 levels,
# the percentage, and the reset time as a local clock hour.
# Omitted entirely when rate_limits.five_hour is absent (API key
# users, or before the first API response in a session).
# =========================================================

rate_limit_display=""
if [ -n "$rate_limit_pct" ]; then
    # Vertical progress bar: map 0–100% to one of 8 block characters
    rate_limit_bar=$(awk -v pct="$rate_limit_pct" 'BEGIN {
        split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", bars, " ")
        idx = int(pct / 100 * 8)
        if (idx < 1) idx = 1
        if (idx > 8) idx = 8
        printf "%s", bars[idx]
    }')

    rate_limit_rounded=$(awk -v pct="$rate_limit_pct" 'BEGIN { printf "%.0f", pct }')

    # Color the rate limit segment using the same thresholds as the context bar
    if   [ "$rate_limit_rounded" -ge 80 ]; then rate_color="$RED"
    elif [ "$rate_limit_rounded" -ge 70 ]; then rate_color="$ORANGE"
    elif [ "$rate_limit_rounded" -ge 60 ]; then rate_color="$YELLOW"
    else                                        rate_color="$GREEN"
    fi

    # Format reset time as a compact local clock hour (e.g. "4pm", "11am")
    reset_time=""
    if [ -n "$rate_limit_resets_at" ]; then
        # Convert Unix epoch to local time (e.g. "4pm", "11am")
        # macOS date uses %l (space-padded hour), so we trim the leading space.
        reset_time=$(/bin/date -j -f "%s" "$rate_limit_resets_at" "+%l%p" 2>/dev/null \
            | tr '[:upper:]' '[:lower:]' \
            | sed 's/^ *//')
    fi

    if [ -n "$reset_time" ]; then
        rate_limit_display=$(printf "  ${rate_color}%s${RESET} ${DIM}%s%%${RESET} ${DIM}(%s)${RESET}" \
            "$rate_limit_bar" "$rate_limit_rounded" "$reset_time")
    else
        rate_limit_display=$(printf "  ${rate_color}%s${RESET} ${DIM}%s%%${RESET}" \
            "$rate_limit_bar" "$rate_limit_rounded")
    fi
fi

# =========================================================
# Shorten directory for display:
#   1. Replace $HOME with ~
#   2. Abbreviate intermediate path components to the shortest
#      unique prefix among their siblings, so the result is
#      unambiguously tab-completable back to the full path.
#      e.g. ~/Development/github/jakobwesthoff/portalis
#        → ~/De/g/j/portalis  (if ~/Documents and ~/Downloads exist)
# =========================================================

# shortest_unique_prefix DIR NAME
# Prints the shortest prefix of NAME that is unique among the
# directory entries in DIR (case-sensitive, directories only).
shortest_unique_prefix() {
    local parent="$1" name="$2"
    local len max siblings

    max=${#name}

    # Collect sibling directory names (excluding the target itself)
    mapfile -t siblings < <(
        find "$parent" -maxdepth 1 -mindepth 1 -type d -not -name "$name" \
            -exec basename {} \; 2>/dev/null
    )

    # If no siblings, one character is enough
    if [ ${#siblings[@]} -eq 0 ]; then
        printf '%s' "${name:0:1}"
        return
    fi

    for (( len=1; len<=max; len++ )); do
        local prefix="${name:0:$len}"
        local collision=false
        for sib in "${siblings[@]}"; do
            if [[ "${sib:0:$len}" == "$prefix" ]]; then
                collision=true
                break
            fi
        done
        if ! $collision; then
            printf '%s' "$prefix"
            return
        fi
    done

    # Full name needed (all siblings share every prefix — unlikely)
    printf '%s' "$name"
}

short_dir="${cwd/#$HOME/\~}"

IFS='/' read -ra parts <<< "$short_dir"
display_dir=""
last_idx=$(( ${#parts[@]} - 1 ))

# Rebuild the real path incrementally so we can inspect siblings
real_path=""

for i in "${!parts[@]}"; do
    part="${parts[$i]}"

    if [ "$i" -eq "$last_idx" ] || [ "$part" = "~" ] || [ -z "$part" ]; then
        # Keep the last component and ~ in full
        display_dir="${display_dir}${part}"
    else
        # Find shortest unique prefix among sibling directories
        if [ "$part" = "~" ]; then
            parent="$HOME"
        elif [ -z "$real_path" ]; then
            parent="/"
        else
            parent="$real_path"
        fi
        abbrev=$(shortest_unique_prefix "$parent" "$part")
        display_dir="${display_dir}${abbrev}"
    fi

    # Track the real filesystem path for the next iteration
    if [ "$part" = "~" ]; then
        real_path="$HOME"
    elif [ -z "$real_path" ] && [ -z "$part" ]; then
        real_path=""
    else
        real_path="${real_path}/${part}"
    fi

    if [ "$i" -lt "$last_idx" ]; then
        display_dir="${display_dir}/"
    fi
done

# =========================================================
# Render the status line
# Format: [Model] │ [Directory]   [Bar] [%] [Tokens]  [Rate ▄ N% (Xpm)]  [$Cost]
# =========================================================

printf "${DIM}%s${RESET} │ ${DIM}%s${RESET}   ${bar_color}%s${RESET} ${DIM}%s%%${RESET}  ${token_color}%s${RESET}%b  ${DIM}[%s]${RESET}\n" \
    "$model_name" \
    "$display_dir" \
    "$bar" \
    "$used" \
    "$token_display" \
    "$rate_limit_display" \
    "$cost_display"
