#!/usr/bin/env bash
# Claude Code status line script
# Displays: [Model] │ [Directory] [Circle Bar] [%] [Helpful message]
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
exceeds_200k=$(echo "$input" | jq -r '.context_window.exceeds_200k_tokens // false')
used_pct_raw=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // "n/a"')

# =========================================================
# Determine context usage percentage
# =========================================================

mode="UNKNOWN"
raw_used=0

if [ "$exceeds_200k" = "true" ]; then
    # Hard override: context definitely exceeded
    raw_used=100
    mode="REALTIME(exceeds_200k)"
elif [ -n "$used_pct_raw" ]; then
    # Real-time mode: Claude Code >= 2.1.72 provides used_percentage directly
    raw_used=$(echo "$used_pct_raw" | awk '{printf "%.2f", $1}')
    mode="REALTIME"
elif [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Fallback mode: parse transcript JSONL for last complete assistant message
    # "Complete" is heuristically defined as total tokens > 1000 to filter streaming artifacts.
    last_tokens=$(grep -o '"type":"assistant"[^}]*"input_tokens":[0-9]*[^}]*"cache_read_input_tokens":[0-9]*' "$transcript_path" 2>/dev/null \
        | awk -F'"input_tokens":' '{print $2}' \
        | awk -F',' '{print $1}' \
        | tail -1)

    # More robust: use jq to find last assistant message with usage.input_tokens > 1000
    last_usage=$(grep -E '"type"\s*:\s*"assistant"' "$transcript_path" 2>/dev/null \
        | jq -s 'map(select(.message.usage.input_tokens != null))
                 | map(select((.message.usage.input_tokens + (.message.usage.cache_read_input_tokens // 0)) > 1000))
                 | last
                 | .message.usage' 2>/dev/null)

    if [ -n "$last_usage" ] && [ "$last_usage" != "null" ]; then
        input_toks=$(echo "$last_usage" | jq -r '.input_tokens // 0')
        cache_toks=$(echo "$last_usage" | jq -r '.cache_read_input_tokens // 0')
        total_toks=$((input_toks + cache_toks))
        raw_used=$(echo "$total_toks" | awk '{printf "%.2f", ($1 / 200000) * 100}')
        total_input_tokens="$total_toks (from transcript)"
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
# Scale and cap percentage
# Scaling formula: used = (rawUsed / 80) * 100, capped at 100
# This treats 80% of the context window as effectively "full"
# to give a more actionable warning earlier.
# =========================================================

used=$(echo "$raw_used" | awk '{
    scaled = ($1 / 80) * 100
    if (scaled > 100) scaled = 100
    printf "%.0f", scaled
}')

# =========================================================
# Debug log (written to stderr so it appears separately from status output)
# =========================================================

>&2 printf "[statusline] mode=%s raw_used=%.2f%% scaled=%s%% total_input_tokens=%s\n" \
    "$mode" "$raw_used" "$used" "$total_input_tokens"

# =========================================================
# Build circle progress bar (10 circles, ● filled / ○ empty)
# =========================================================

filled=$(echo "$used" | awk '{
    n = int($1 / 10)
    if (n > 10) n = 10
    print n
}')
empty=$((10 - filled))

# Choose color based on scaled percentage
if   [ "$used" -ge 80 ]; then bar_color="$RED"
elif [ "$used" -ge 70 ]; then bar_color="$ORANGE"
elif [ "$used" -ge 60 ]; then bar_color="$YELLOW"
else                          bar_color="$GREEN"
fi

bar=""
for ((i=0; i<filled; i++)); do bar="${bar}●"; done
for ((i=0; i<empty;  i++)); do bar="${bar}○"; done

# =========================================================
# Helpful contextual message based on usage level
# =========================================================

if   [ "$used" -ge 100 ]; then hint="🔴 Context full — start a new session"
elif [ "$used" -ge 80  ]; then hint="🟠 Getting crowded — consider /compact"
elif [ "$used" -ge 60  ]; then hint="🟡 Halfway there"
elif [ "$used" -ge 30  ]; then hint="🟢 Plenty of context left"
else                           hint="✨ Fresh session"
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
# Format: [Model] │ [Directory]   [Bar] [%] [Hint]
# =========================================================

printf "${DIM}%s${RESET} │ ${DIM}%s${RESET}   ${bar_color}%s${RESET} ${DIM}%s%%${RESET}  %s\n" \
    "$model_name" \
    "$display_dir" \
    "$bar" \
    "$used" \
    "$hint"
