#!/bin/bash
set -ueo pipefail

_escape_for_regexp() {
  gsed 's/\[\|\]\|[/.|${}*^]/\\&/g' <<<"$*"
}

# Make human readable with two decimals
_human_readable() {
  local bytes="${1}"
awk -v bytes="$bytes" '
            function human(x) {
                s="bkMGTEPZY"; while (x>=1000 && length(s)>1) {x/=1024; s=substr(s,2)}
                return sprintf("%.2f%s", x, substr(s,1,1))
            }
            BEGIN {print human(bytes)}
        '
}

usage() {
  echo "$(basename "${0}") <max size in bytes> <src dir> <target dir> [<start at filename>]"
  echo "Created directories in target dir a relative to CWD."
}

main() {
  if [ $# -eq 1 ] && [ "$1" == "--help" ]; then
    usage
    exit
  fi

  if [ $# -lt 3 ]; then
    usage
    exit 1
  fi

  local size_limit="$1"
  local src="$2"
  local dst="$3"
  local start=""

  if [ "$#" -gt 3 ]; then
    start="${4}"
  fi

  local list_tmp
  list_tmp="$(mktemp)"

  echo "Scanning files..."
  find -s "${src}" -type f -not -iname ".*" |sort -Vs >"${list_tmp}"
  
  if [ -n "$start" ]; then
    local filtered_list_tmp
    filtered_list_tmp="$(mktemp)"

    local escaped_start
    escaped_start="$(_escape_for_regexp "$start")"
    gsed -n "/^${escaped_start}/,\$p" "${list_tmp}" >"${filtered_list_tmp}"
#    gsed '0,/^'"$(_escape_for_regexp "$start")"'$/d' "${list_tmp}" >>"${filtered_list_tmp}"
    
    rm "${list_tmp}"
    list_tmp="$filtered_list_tmp"
  fi

  local bytecounter=0

  while read -r file ; do
    local file_size
    file_size="$(stat --printf="%s" "${file}")"
    local bytecounter_after_increment
    bytecounter_after_increment="$((bytecounter + file_size))"

    if [[ "$bytecounter_after_increment" -gt "$size_limit" ]]; then
      echo ""
      echo "Size limit reached. Collected bytes: ${bytecounter} ($(_human_readable "$bytecounter"))"
      echo "Last file which did not fit anymore:"
      echo "$file"
      exit 0
    fi

    bytecounter="$bytecounter_after_increment"

    local relative_dirname
    relative_dirname="$(dirname "$file")"
    full_dst="${dst}/${relative_dirname}"

    if [ ! -d "${full_dst}" ]; then 
      mkdir -p "${full_dst}"
    fi

    local filename_only
    filename_only="$(basename "$file")"

    echo 
    echo "($(_human_readable "$bytecounter")) [$(_human_readable "$file_size")] -- $file"
    pv "$file" >"${full_dst}/${filename_only}"
  done < "${list_tmp}"

  rm "${list_tmp}"
}

main "$@"
