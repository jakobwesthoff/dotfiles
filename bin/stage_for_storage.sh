#!/bin/bash
set -ueo pipefail

_escape_for_regexp() {
  # shellcheck disable=SC2001,SC2016
  sed 's/[][\.|$(){}?+*^]/\\&/g' <<<"$*"
}

main() {
  local size_limit="$1"
  local src="$2"
  local dst="$3"
  local start=""

  if [ "$#" -gt 3 ]; then
    start="${4}"
  fi

  local list_tmp="$(mktemp)"

  echo "Scanning files..."
  find -s "${src}" -type f -not -iname ".*" |sort -Vs >"${list_tmp}"
  
  if [ -n "$start" ]; then
    local filtered_list_tmp="$(mktemp)"

    echo "$start" >"$filtered_list_tmp"
    sed '0,/^'"$(_escape_for_regexp "$start")"'$/d' "${list_tmp}" >>"${filtered_list_tmp}"
    
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
      echo "Size limit reached. Collected bytes: ${bytecounter}"
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

    local filename_only="$(basename "$file")"
    echo 
    echo "($bytecounter) [$file_size] -- $file"
    pv "$file" >"${full_dst}/${filename_only}"
  done < "${list_tmp}"

  rm "${list_tmp}"
}

main "$@"
