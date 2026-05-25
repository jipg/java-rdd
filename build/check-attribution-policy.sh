#!/usr/bin/env bash

set -euo pipefail

readonly ATTRIBUTION_PATTERN='(generated|created|made|produced|written|authored|built|crafted|realizado|generado|creado|hecho|producido|realizado|escrito|elaborado)[[:space:]]+(with|by|using|via|con|por)'
readonly DISALLOWED_PATTERN="${ATTRIBUTION_PATTERN}"

usage() {
  cat <<'EOF'
Usage:
  build/check-attribution-policy.sh --commit-msg-file <path>
  build/check-attribution-policy.sh --staged
  build/check-attribution-policy.sh --file <path>
  build/check-attribution-policy.sh --text <value>

Fails when commit metadata, staged content, or arbitrary text contains
automated authorship or tool-attribution wording.
EOF
}

check_stream() {
  local source_label="$1"
  local content="$2"
  local temp_file

  temp_file="$(mktemp)"

  if printf '%s\n' "${content}" | grep -Ein "${DISALLOWED_PATTERN}" >"${temp_file}"; then
    echo "Disallowed attribution text found in ${source_label}:" >&2
    sed 's/^/  /' "${temp_file}" >&2
    rm -f "${temp_file}"
    return 1
  fi

  rm -f "${temp_file}"
  return 0
}

check_commit_message_file() {
  local message_file="$1"
  check_stream "commit message" "$(cat "${message_file}")"
}

check_generic_file() {
  local input_file="$1"
  check_stream "file ${input_file}" "$(cat "${input_file}")"
}

check_text() {
  local input_text="$1"
  check_stream "provided text" "${input_text}"
}

check_staged_diff() {
  local staged_patch
  staged_patch="$(git diff --cached --no-color --unified=0 --diff-filter=ACMR)"

  if [[ -z "${staged_patch}" ]]; then
    return 0
  fi

  check_stream "staged changes" "$(printf '%s\n' "${staged_patch}" | grep -E '^\+[^+]' | sed 's/^\+//')"
}

if [[ $# -ne 1 && $# -ne 2 ]]; then
  usage >&2
  exit 1
fi

case "$1" in
  --commit-msg-file)
    if [[ $# -ne 2 ]]; then
      usage >&2
      exit 1
    fi

    check_commit_message_file "$2"
    ;;
  --file)
    if [[ $# -ne 2 ]]; then
      usage >&2
      exit 1
    fi

    check_generic_file "$2"
    ;;
  --staged)
    if [[ $# -ne 1 ]]; then
      usage >&2
      exit 1
    fi

    check_staged_diff
    ;;
  --text)
    if [[ $# -ne 2 ]]; then
      usage >&2
      exit 1
    fi

    check_text "$2"
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
