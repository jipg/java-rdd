#!/usr/bin/env bash
# =============================================================================
# validate-alert-runbook.sh — Alert ↔ Runbook Coverage Validator
# =============================================================================
#
# WHY THIS SCRIPT EXISTS:
#   Every production alert MUST have a corresponding runbook. An alert
#   without a runbook means an on-call engineer is woken up at 3 AM with
#   no guidance — leading to longer MTTR and higher stress.
#
#   This script cross-references alert definitions in
#   /observability/dynatrace/alerts/ against runbook files in /runbooks/.
#   It runs as part of the definition-of-done workflow.
#
# HOW IT WORKS:
#   1. Scans /observability/dynatrace/alerts/*.yml for `runbook:` fields
#   2. Verifies each referenced runbook file exists in /runbooks/
#   3. Optionally checks for orphaned runbooks (no alert references them)
#
# USAGE:
#   ./build/validate-alert-runbook.sh [--strict] [--check-orphans]
#     --strict:        exit code 1 on any alert without a runbook (CI mode)
#     --check-orphans: also report runbooks not referenced by any alert
#
# EXIT CODES:
#   0 — All alerts have runbooks (or no alert files exist)
#   1 — (strict mode) One or more alerts missing runbooks
#   2 — Script error
# =============================================================================

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ALERTS_DIR="${REPO_ROOT}/observability/dynatrace/alerts"
RUNBOOKS_DIR="${REPO_ROOT}/runbooks"
STRICT=false
CHECK_ORPHANS=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --strict) STRICT=true ;;
        --check-orphans) CHECK_ORPHANS=true ;;
        --help|-h)
            echo "Usage: $0 [--strict] [--check-orphans]"
            echo "  --strict         Exit with code 1 on missing runbooks (CI mode)"
            echo "  --check-orphans  Report runbooks not referenced by any alert"
            exit 0
            ;;
    esac
done

echo "=== Alert ↔ Runbook Coverage Check ==="
echo ""

# --- Step 1: Check directories exist ---
if [ ! -d "$ALERTS_DIR" ]; then
    echo "INFO: Alerts directory not found: ${ALERTS_DIR}"
    echo "      No alerts to validate. Skipping."
    exit 0
fi

if [ ! -d "$RUNBOOKS_DIR" ]; then
    echo "WARN: Runbooks directory not found: ${RUNBOOKS_DIR}"
    echo "      Create runbooks in /runbooks/ for each alert."
    if [ "$STRICT" = true ]; then
        exit 1
    fi
    exit 0
fi

# --- Step 2: Find alert definition files ---
ALERT_FILES=$(find "$ALERTS_DIR" -name "*.yml" -o -name "*.yaml" 2>/dev/null | sort)

if [ -z "$ALERT_FILES" ]; then
    echo "INFO: No alert definition files (*.yml) found in ${ALERTS_DIR}"
    echo "      Add alert definitions as YAML files."
    exit 0
fi

ALERT_COUNT=$(echo "$ALERT_FILES" | wc -l | tr -d ' ')
echo "Found ${ALERT_COUNT} alert definition(s)."
echo ""

# --- Step 3: Extract runbook references and validate ---
MISSING=0
COVERED=0
REFERENCED_RUNBOOKS=$(mktemp)
trap 'rm -f "$REFERENCED_RUNBOOKS"' EXIT

while IFS= read -r alert_file; do
    alert_name=$(basename "$alert_file" | sed 's/\.\(yml\|yaml\)$//')

    # Extract runbook field value
    runbook_ref=$(grep -E '^[[:space:]]*runbook:' "$alert_file" 2>/dev/null \
        | head -1 \
        | sed 's/.*runbook:[[:space:]]*//' \
        | sed 's/^["'"'"']//' \
        | sed 's/["'"'"']$//' \
        | tr -d ' ')

    if [ -z "$runbook_ref" ]; then
        echo "FAIL: Alert '${alert_name}' has no 'runbook:' field."
        MISSING=$((MISSING + 1))
        continue
    fi

    # Resolve runbook path (could be absolute from repo root or relative)
    runbook_path="${runbook_ref#/}"  # Remove leading slash
    full_path="${REPO_ROOT}/${runbook_path}"

    if [ -f "$full_path" ]; then
        echo "  OK: Alert '${alert_name}' → ${runbook_ref}"
        COVERED=$((COVERED + 1))
        echo "$runbook_path" >> "$REFERENCED_RUNBOOKS"
    else
        echo "FAIL: Alert '${alert_name}' references '${runbook_ref}' but file not found."
        MISSING=$((MISSING + 1))
    fi
done <<< "$ALERT_FILES"

echo ""
echo "Coverage: ${COVERED}/${ALERT_COUNT} alerts have valid runbooks."

# --- Step 4: Check for orphaned runbooks (optional) ---
if [ "$CHECK_ORPHANS" = true ]; then
    echo ""
    echo "=== Orphaned Runbook Check ==="

    ORPHAN_COUNT=0
    while IFS= read -r -d '' runbook_file; do
        rel_path="${runbook_file#${REPO_ROOT}/}"
        runbook_name=$(basename "$runbook_file")

        # Skip template
        if [ "$runbook_name" = "template.md" ]; then
            continue
        fi

        if ! grep -qF "$rel_path" "$REFERENCED_RUNBOOKS" 2>/dev/null; then
            echo "WARN: Runbook '${rel_path}' is not referenced by any alert."
            ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
        fi
    done < <(find "$RUNBOOKS_DIR" -name "*.md" -type f -print0 2>/dev/null)

    if [ "$ORPHAN_COUNT" -eq 0 ]; then
        echo "  OK: No orphaned runbooks found."
    else
        echo "INFO: ${ORPHAN_COUNT} orphaned runbook(s) found."
        echo "      These may be valid (referenced by external systems) or stale."
    fi
fi

# --- Step 5: Final result ---
echo ""
if [ "$MISSING" -gt 0 ]; then
    echo "=== RESULT: ${MISSING} alert(s) missing runbook coverage ==="
    echo ""
    echo "Fix by either:"
    echo "  1. Creating a runbook in /runbooks/ for the uncovered alert"
    echo "  2. Adding a 'runbook:' field to the alert YAML pointing to the file"
    echo ""
    if [ "$STRICT" = true ]; then
        echo "STRICT MODE: Failing with exit code 1."
        exit 1
    else
        echo "NON-STRICT MODE: Exiting with warnings only."
        exit 0
    fi
else
    echo "=== RESULT: All alerts have valid runbook coverage ==="
    exit 0
fi
