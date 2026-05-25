#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CHECK_SCRIPT="${SCRIPT_DIR}/check-attribution-policy.sh"

usage() {
  cat <<'EOF'
Usage:
  build/gh-pr-safe.sh create [gh pr create args...]
  build/gh-pr-safe.sh edit [gh pr edit args...]

Validates PR title/body inputs before delegating to `gh pr create` or
`gh pr edit`.
EOF
}

validate_args() {
  local -a args=("$@")
  local index=0

  while [[ ${index} -lt ${#args[@]} ]]; do
    case "${args[${index}]}" in
      --title)
        index=$((index + 1))
        [[ ${index} -lt ${#args[@]} ]] || { echo "Missing value for --title" >&2; exit 1; }
        "${CHECK_SCRIPT}" --text "${args[${index}]}"
        ;;
      --body)
        index=$((index + 1))
        [[ ${index} -lt ${#args[@]} ]] || { echo "Missing value for --body" >&2; exit 1; }
        "${CHECK_SCRIPT}" --text "${args[${index}]}"
        ;;
      --body-file)
        index=$((index + 1))
        [[ ${index} -lt ${#args[@]} ]] || { echo "Missing value for --body-file" >&2; exit 1; }
        "${CHECK_SCRIPT}" --file "${args[${index}]}"
        ;;
      --fill|--fill-first|--fill-verbose)
        echo "Refusing ${args[${index}]} because generated PR text cannot be validated deterministically." >&2
        echo "Provide --title and --body or --body-file explicitly." >&2
        exit 1
        ;;
    esac

    index=$((index + 1))
  done
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

subcommand="$1"
shift

case "${subcommand}" in
  create)
    validate_args "$@"
    exec gh pr create "$@"
    ;;
  edit)
    validate_args "$@"
    exec gh pr edit "$@"
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
