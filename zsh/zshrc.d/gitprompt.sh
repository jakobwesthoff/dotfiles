# Adapted from code found at <https://gist.github.com/1712320> and
# <https://gist.github.com/joshdick/4415470>.

autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="%{$fg[green]%}(%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%})%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}↑NUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}↓NUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}●%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_BRANCH_TRACKING=""
  local GIT_LOCAL_STATUS=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_BRANCH_TRACKING=${GIT_BRANCH_TRACKING}${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_BRANCH_TRACKING=${GIT_BRANCH_TRACKING}${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_BRANCH_TRACKING=${GIT_BRANCH_TRACKING}${GIT_PROMPT_MERGING}
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_LOCAL_STATUS=${GIT_LOCAL_STATUS}${GIT_PROMPT_UNTRACKED}
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_LOCAL_STATUS=${GIT_LOCAL_STATUS}${GIT_PROMPT_MODIFIED}
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_LOCAL_STATUS=${GIT_LOCAL_STATUS}${GIT_PROMPT_STAGED}
  fi

  local result_state=""

  if [[ -n ${GIT_BRANCH_TRACKING} ]]; then
      result_state="${result_state}${GIT_BRANCH_TRACKING} | "
  fi

    if [[ -n ${GIT_LOCAL_STATUS} ]]; then
        result_state="${result_state}${GIT_LOCAL_STATUS}"
    fi

  if [[ -n ${result_state} ]]; then
    echo "${GIT_PROMPT_PREFIX}${result_state}${GIT_PROMPT_SUFFIX}"
  fi

}

# If inside a Git repository, print its branch and state
_r9e_prompt_function_git_prompt() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}
_r9e_prompt_register_volatile_command 'git_prompt'

