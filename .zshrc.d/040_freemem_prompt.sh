autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
FREEMEM_PROMPT_PREFIX="["
FREEMEM_PROMPT_SUFFIX="]"

# Shamelessly taken from https://github.com/bhilburn/powerlevel9k/blob/master/functions/utilities.zsh
# Converts large memory values into a human-readable unit (e.g., bytes --> GB)
# Takes two arguments:
#   * $size - The number which should be prettified
#   * $base - The base of the number (default Bytes)
freemem_printSizeHumanReadable() {
  typeset -F 2 size
  size="$1"+0.00001
  local extension
  extension=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')
  local index=1

  # if the base is not Bytes
  if [[ -n $2 ]]; then
    local idx
    for idx in "${extension[@]}"; do
      if [[ "$2" == "$idx" ]]; then
        break
      fi
      index=$(( index + 1 ))
    done
  fi

  while (( (size / 1024) > 0.1 )); do
    size=$(( size / 1024 ))
    index=$(( index + 1 ))
  done

  echo "$size${extension[$index]}"
}

# If inside a Git repository, print its branch and state
_r9e_prompt_function_freemem_prompt() {
  local base=''
  local ramfree=0
  local pagesize
  # macOS Specific
  # Available = Free + Inactive
  # See https://support.apple.com/en-us/HT201538
  ramfree=$(vm_stat | grep "Pages free" | grep -o -E '[0-9]+')
  ramfree=$((ramfree + $(vm_stat | grep "Pages inactive" | grep -o -E '[0-9]+')))
  # Convert pages into Bytes
  pagesize="$(vm_stat|grep "page size of"|grep -o -E '[0-9]+')"
  ramfree=$(( ramfree * pagesize ))

  echo "${FREEMEM_PROMPT_PREFIX}%{$fg[blue]%}$(freemem_printSizeHumanReadable ${ramfree} $base)%{$reset_color%}${FREEMEM_PROMPT_SUFFIX}"
}
_r9e_prompt_register_volatile_command 'freemem_prompt'
