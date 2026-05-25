#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly ALLOWLIST_FILE="${COAUTHOR_ALLOWLIST_FILE:-${REPO_ROOT}/build/allowed-coauthors.txt}"
ALLOWLIST_NORMALIZED=""

usage() {
  cat <<'EOF'
Usage:
  build/check-commit-coauthors.sh --commit-msg-file <path>
  build/check-commit-coauthors.sh --commit <sha>
  build/check-commit-coauthors.sh --range <git-range>

Fails when a commit message contains a Co-authored-by trailer whose
normalized "name <email>" entry is not listed in build/allowed-coauthors.txt.
EOF
}

normalize_line() {
  local value="$1"
  printf '%s' "${value}" | tr '[:upper:]' '[:lower:]' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

load_allowlist() {
  if [[ ! -f "${ALLOWLIST_FILE}" ]]; then
    echo "Missing allowlist file: ${ALLOWLIST_FILE}" >&2
    exit 1
  fi

  while IFS= read -r line; do
    local normalized
    normalized="$(normalize_line "${line}")"

    if [[ -z "${normalized}" || "${normalized}" == \#* ]]; then
      continue
    fi

    ALLOWLIST_NORMALIZED+="${normalized}"$'\n'
  done < "${ALLOWLIST_FILE}"
}

extract_from_message_file() {
  local message_file="$1"
  grep -i '^Co-authored-by:' "${message_file}" | sed -E 's/^[^:]+:[[:space:]]*//' || true
}

extract_from_commit() {
  local commit_sha="$1"
  git show -s --format=%B "${commit_sha}" | grep -i '^Co-authored-by:' | sed -E 's/^[^:]+:[[:space:]]*//' || true
}

is_allowed_entry() {
  local normalized_entry="$1"
  grep -Fqx "${normalized_entry}" <<< "${ALLOWLIST_NORMALIZED}"
}

validate_entries() {
  local source_label="$1"
  local has_errors=0

  while IFS= read -r entry; do
    local normalized
    normalized="$(normalize_line "${entry}")"

    if [[ -z "${normalized}" ]]; then
      continue
    fi

    if ! is_allowed_entry "${normalized}"; then
      echo "Disallowed co-author in ${source_label}: ${entry}" >&2
      has_errors=1
    fi
  done

  return "${has_errors}"
}

validate_commit_range() {
  local git_range="$1"
  local has_errors=0

  while IFS= read -r commit_sha; do
    if ! extract_from_commit "${commit_sha}" | validate_entries "commit ${commit_sha}"; then
      has_errors=1
    fi
  done < <(git rev-list "${git_range}")

  return "${has_errors}"
}

if [[ $# -ne 2 ]]; then
  usage >&2
  exit 1
fi

load_allowlist

case "$1" in
  --commit-msg-file)
    if ! extract_from_message_file "$2" | validate_entries "commit message"; then
      exit 1
    fi
    ;;
  --commit)
    if ! extract_from_commit "$2" | validate_entries "commit $2"; then
      exit 1
    fi
    ;;
  --range)
    if ! validate_commit_range "$2"; then
      exit 1
    fi
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
