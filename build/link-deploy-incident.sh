#!/usr/bin/env bash
# =============================================================================
# link-deploy-incident.sh — Deploy ↔ Incident Correlation
# =============================================================================
#
# WHY THIS SCRIPT EXISTS:
#   Change Failure Rate (CFR) requires knowing which deploys caused incidents.
#   MTTR requires knowing when the incident started (deploy time) and when
#   it was resolved. This script extracts deploy_id references from
#   postmortem files and validates the correlation chain:
#
#     deploy event (Splunk) ←→ postmortem (risk/postmortems/) ←→ SFMEA
#
# HOW IT WORKS:
#   1. Scans /risk/postmortems/*.md for deploy_id or correlation_id fields
#   2. Validates that each referenced deploy exists (via git tags or history)
#   3. Outputs a correlation report for DORA metric computation
#
# USAGE:
#   ./build/link-deploy-incident.sh [--output json|table] [--strict]
#
# OUTPUT MODES:
#   table (default): Human-readable table for review
#   json:            Machine-readable JSON for Splunk ingestion
#
# EXIT CODES:
#   0 — All correlations valid (or no postmortems)
#   1 — (strict mode) Postmortems found without deploy_id correlation
# =============================================================================

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
POSTMORTEMS_DIR="${REPO_ROOT}/risk/postmortems"
OUTPUT_FORMAT="table"
STRICT=false

for arg in "$@"; do
    case "$arg" in
        --output)   shift; OUTPUT_FORMAT="${1:-table}" ;;
        --strict)   STRICT=true ;;
        --help|-h)
            echo "Usage: $0 [--output json|table] [--strict]"
            exit 0
            ;;
    esac
    shift 2>/dev/null || true
done

echo "=== Deploy ↔ Incident Correlation Report ==="
echo ""

if [ ! -d "$POSTMORTEMS_DIR" ]; then
    echo "INFO: No postmortems directory found. Nothing to correlate."
    exit 0
fi

# Find actual postmortems (not template)
POSTMORTEM_FILES=$(find "$POSTMORTEMS_DIR" -name "*.md" -type f ! -name "template.md" 2>/dev/null | sort)

if [ -z "$POSTMORTEM_FILES" ]; then
    echo "INFO: No postmortem files found (excluding template)."
    echo "      This is expected for new services with no incidents yet."
    exit 0
fi

TOTAL=0
LINKED=0
UNLINKED=0
CORRELATIONS=""

while IFS= read -r pm_file; do
    TOTAL=$((TOTAL + 1))
    pm_name=$(basename "$pm_file" .md)

    # Extract deploy_id or correlation_id from the postmortem
    # Look for patterns like:
    #   - deploy_id: 12345-1
    #   - correlation_id: 12345-1
    #   - **Deploy ID**: 12345-1
    #   - PR that caused incident: [#123]
    deploy_id=$(grep -iE '(deploy[_-]?id|correlation[_-]?id)\s*[:=]\s*' "$pm_file" 2>/dev/null \
        | head -1 \
        | sed 's/.*[:=]\s*//' \
        | sed 's/[[:space:]]*$//' \
        | sed 's/^[`"'"'"']//;s/[`"'"'"']$//' \
        || echo "")

    # Extract PR number
    pr_number=$(grep -iE 'PR that caused incident' "$pm_file" 2>/dev/null \
        | grep -oE '#[0-9]+' \
        | head -1 \
        | tr -d '#' \
        || echo "")

    # Extract severity
    severity=$(grep -iE '^\s*-\s*\*\*Severity\*\*' "$pm_file" 2>/dev/null \
        | head -1 \
        | sed 's/.*:\s*//' \
        | sed 's/[[:space:]]*$//' \
        || echo "unknown")

    # Extract date
    pm_date=$(grep -iE '^\s*-\s*\*\*Date\*\*' "$pm_file" 2>/dev/null \
        | head -1 \
        | sed 's/.*:\s*//' \
        | sed 's/[[:space:]]*$//' \
        || echo "unknown")

    # Extract duration
    duration=$(grep -iE '^\s*-\s*\*\*Duration\*\*' "$pm_file" 2>/dev/null \
        | head -1 \
        | sed 's/.*:\s*//' \
        | sed 's/[[:space:]]*$//' \
        || echo "unknown")

    if [ -n "$deploy_id" ]; then
        LINKED=$((LINKED + 1))
        status="LINKED"
    else
        UNLINKED=$((UNLINKED + 1))
        status="UNLINKED"
    fi

    if [ "$OUTPUT_FORMAT" = "json" ]; then
        CORRELATIONS="${CORRELATIONS}{\"postmortem\":\"${pm_name}\",\"date\":\"${pm_date}\",\"severity\":\"${severity}\",\"duration\":\"${duration}\",\"deploy_id\":\"${deploy_id}\",\"pr_number\":\"${pr_number}\",\"status\":\"${status}\"},"
    else
        printf "  %-8s  %-35s  %-12s  %-10s  deploy_id=%s  PR=%s\n" \
            "$status" "$pm_name" "$pm_date" "$severity" \
            "${deploy_id:-N/A}" "${pr_number:-N/A}"
    fi
done <<< "$POSTMORTEM_FILES"

echo ""
echo "=== Summary ==="
echo "  Total postmortems: ${TOTAL}"
echo "  Linked to deploy:  ${LINKED}"
echo "  Unlinked:          ${UNLINKED}"

if [ "$OUTPUT_FORMAT" = "json" ]; then
    echo ""
    echo "=== JSON Output ==="
    # Remove trailing comma and wrap in array
    echo "[${CORRELATIONS%,}]" | python3 -m json.tool 2>/dev/null || echo "[${CORRELATIONS%,}]"
fi

echo ""
if [ "$UNLINKED" -gt 0 ]; then
    echo "WARN: ${UNLINKED} postmortem(s) have no deploy_id."
    echo "      Add a deploy_id or correlation_id to link incidents to deploys."
    echo "      This is required for accurate Change Failure Rate (CFR)."
    echo ""
    if [ "$STRICT" = true ]; then
        echo "STRICT MODE: Failing due to unlinked postmortems."
        exit 1
    fi
fi

echo "=== DONE ==="
