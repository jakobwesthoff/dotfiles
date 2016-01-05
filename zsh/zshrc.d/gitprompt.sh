#@IgnoreInspection BashAddShebang
# Adapted from code found at <https://gist.github.com/1712320> and
# <https://gist.github.com/joshdick/4415470>.

autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="("
GIT_PROMPT_SUFFIX=")"
GIT_PROMPT_AHEAD="%{$fg[green]%}↑NUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}↓NUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}+NUM%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[blue]%}●NUM%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[yellow]%}●NUM%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {
  # Compose this value via multiple conditional appends.
  local git_branch_tracking=""
  local git_local_status=""

  local num_ahead="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$num_ahead" -gt 0 ]; then
    git_branch_tracking="${git_branch_tracking} ${GIT_PROMPT_AHEAD//NUM/$num_ahead}"
  fi

  local num_behind="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$num_behind" -gt 0 ]; then
    git_branch_tracking="${git_branch_tracking} ${GIT_PROMPT_BEHIND//NUM/$num_behind}"
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    git_branch_tracking="${git_branch_tracking} ${GIT_PROMPT_MERGING}"
  fi

  local untracked_count="$(git ls-files --others --exclude-standard | wc -l)"
  if [ "${untracked_count}" -gt 0 ]; then
    git_local_status="${git_local_status} ${GIT_PROMPT_UNTRACKED//NUM/${untracked_count}}"
  fi

  local modified_count="$(git diff --name-status | wc -l)"
  if [ "${modified_count}" -gt 0 ]; then
    git_local_status="${git_local_status} ${GIT_PROMPT_MODIFIED//NUM/${modified_count}}"
  fi

  local staged_count="$(git diff --cached --name-status | wc -l)"
  if [ "${staged_count}" -gt 0 ]; then
    git_local_status="${git_local_status} ${GIT_PROMPT_STAGED//NUM/${staged_count}}"
  fi

  local result_state=""

  if [[ -n ${git_branch_tracking} ]]; then
      git_branch_tracking="${git_branch_tracking## }"
      git_branch_tracking="${git_branch_tracking%% }"
      result_state="${result_state}${git_branch_tracking}"
  fi

  if [[ -n ${git_local_status} ]]; then
    git_local_status="${git_local_status## }"
    git_local_status="${git_local_status%% }"
    result_state="${result_state} ${git_local_status}"
  fi

  result_state="${result_state## }"

  if [[ -n ${result_state} ]]; then
    echo "${GIT_PROMPT_PREFIX}${result_state}${GIT_PROMPT_SUFFIX}"
  fi
}

# If inside a Git repository, print its branch and state
_r9e_prompt_function_git_prompt() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$(parse_git_state)${GIT_PROMPT_PREFIX}%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}%{$reset_color%}${GIT_PROMPT_SUFFIX}"
}
_r9e_prompt_register_volatile_command 'git_prompt'

