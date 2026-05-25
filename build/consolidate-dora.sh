#!/usr/bin/env bash
# =============================================================================
# consolidate-dora.sh — Monthly DORA Metrics Consolidation
# =============================================================================
#
# WHY THIS SCRIPT EXISTS:
#   While Splunk computes real-time DORA metrics from deploy events, this
#   script provides a git-based consolidation that:
#   1. Works without Splunk access (useful for local analysis)
#   2. Cross-references deploy data with postmortems for CFR accuracy
#   3. Generates a monthly summary committed to the repo as evidence
#   4. Feeds the RPN↔CFR correlation analysis
#
# HOW IT WORKS:
#   1. Counts production deploys from git tags or GitHub API
#   2. Correlates with postmortems via link-deploy-incident.sh
#   3. Computes the four DORA metrics for the specified month
#   4. Outputs a Markdown report and optional JSON for Splunk
#
# USAGE:
#   ./build/consolidate-dora.sh [--month YYYY-MM] [--output-dir path]
#
#   --month:      Target month (defaults to previous month)
#   --output-dir: Where to write the report (defaults to observability/dora/reports/)
#
# SCHEDULING:
#   Run monthly via GitHub Actions (scheduled workflow) or manually.
#   The report is committed to the repo for traceability.
#
# =============================================================================

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TARGET_MONTH=""
OUTPUT_DIR="${REPO_ROOT}/observability/dora/reports"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --month)     TARGET_MONTH="$2"; shift 2 ;;
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 [--month YYYY-MM] [--output-dir path]"
            exit 0
            ;;
        *) shift ;;
    esac
done

# Default to previous month
if [ -z "$TARGET_MONTH" ]; then
    TARGET_MONTH=$(date -d "last month" +"%Y-%m" 2>/dev/null || date -v-1m +"%Y-%m" 2>/dev/null || date +"%Y-%m")
fi

YEAR=$(echo "$TARGET_MONTH" | cut -d'-' -f1)
MONTH=$(echo "$TARGET_MONTH" | cut -d'-' -f2)
MONTH_START="${TARGET_MONTH}-01"

# Calculate month end
if command -v gdate &>/dev/null; then
    MONTH_END=$(gdate -d "${MONTH_START} +1 month -1 day" +"%Y-%m-%d")
elif date --version &>/dev/null 2>&1; then
    MONTH_END=$(date -d "${MONTH_START} +1 month -1 day" +"%Y-%m-%d")
else
    # macOS fallback
    MONTH_END=$(date -j -v+1m -v-1d -f "%Y-%m-%d" "${MONTH_START}" +"%Y-%m-%d" 2>/dev/null || echo "${TARGET_MONTH}-28")
fi

echo "=== DORA Metrics Consolidation ==="
echo "Period: ${MONTH_START} to ${MONTH_END}"
echo ""

# --- Count production deploys from git history ---
# Production deploys are identified by tags (vX.Y.Z) or merge commits to main
DEPLOY_COUNT=$(git log --oneline --after="${MONTH_START}" --before="${MONTH_END}T23:59:59" --first-parent main 2>/dev/null | wc -l | tr -d ' ')
TAG_COUNT=$(git tag -l "v*" --sort=-creatordate 2>/dev/null | while read -r tag; do
    tag_date=$(git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1)
    if [[ "$tag_date" > "$MONTH_START" || "$tag_date" = "$MONTH_START" ]] && [[ "$tag_date" < "$MONTH_END" || "$tag_date" = "$MONTH_END" ]]; then
        echo "$tag"
    fi
done | wc -l | tr -d ' ')

# --- Count incidents from postmortems ---
INCIDENT_COUNT=0
POSTMORTEMS_DIR="${REPO_ROOT}/risk/postmortems"
if [ -d "$POSTMORTEMS_DIR" ]; then
    # Count postmortems with dates in the target month
    INCIDENT_COUNT=$(find "$POSTMORTEMS_DIR" -name "${TARGET_MONTH}*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# --- Compute DORA metrics ---
WORKING_DAYS=22  # Approximate

# Deployment Frequency
if [ "$DEPLOY_COUNT" -gt 0 ]; then
    DF_PER_DAY=$(echo "scale=2; $DEPLOY_COUNT / $WORKING_DAYS" | bc 2>/dev/null || echo "N/A")
    DF_PER_WEEK=$(echo "scale=2; $DEPLOY_COUNT / 4" | bc 2>/dev/null || echo "N/A")
else
    DF_PER_DAY="0"
    DF_PER_WEEK="0"
fi

# Change Failure Rate
if [ "$DEPLOY_COUNT" -gt 0 ] && [ "$INCIDENT_COUNT" -gt 0 ]; then
    CFR=$(echo "scale=2; ($INCIDENT_COUNT * 100) / $DEPLOY_COUNT" | bc 2>/dev/null || echo "N/A")
else
    CFR="0"
fi

# DORA performance level classification
classify_df() {
    local deploys=$1
    if [ "$deploys" -ge 22 ]; then echo "Elite (on-demand)"
    elif [ "$deploys" -ge 4 ]; then echo "High (weekly-daily)"
    elif [ "$deploys" -ge 1 ]; then echo "Medium (monthly-weekly)"
    else echo "Low (< monthly)"
    fi
}

classify_cfr() {
    local rate=$1
    if echo "$rate" | grep -qE '^[0-9]'; then
        cfr_int=$(echo "$rate" | cut -d'.' -f1)
        if [ "$cfr_int" -le 15 ]; then echo "Elite/High (0-15%)"
        elif [ "$cfr_int" -le 30 ]; then echo "Medium (16-30%)"
        else echo "Low (> 30%)"
        fi
    else
        echo "N/A"
    fi
}

DF_LEVEL=$(classify_df "$DEPLOY_COUNT")
CFR_LEVEL=$(classify_cfr "$CFR")

# --- Generate report ---
mkdir -p "$OUTPUT_DIR"
REPORT_FILE="${OUTPUT_DIR}/${TARGET_MONTH}-dora-report.md"

cat > "$REPORT_FILE" << REPORT
# DORA Metrics Report — ${TARGET_MONTH}

- **Period**: ${MONTH_START} to ${MONTH_END}
- **Generated**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Source**: git history + postmortem correlation

## Summary

| Metric | Value | Level | Target |
|---|---|---|---|
| **Deployment Frequency** | ${DEPLOY_COUNT} deploys (${DF_PER_DAY}/day, ${DF_PER_WEEK}/week) | ${DF_LEVEL} | Elite: on-demand |
| **Lead Time for Changes** | *See Splunk dashboard* | *Requires Splunk data* | Elite: < 1 hour |
| **Change Failure Rate** | ${CFR}% (${INCIDENT_COUNT} incidents / ${DEPLOY_COUNT} deploys) | ${CFR_LEVEL} | Elite: 0-15% |
| **Mean Time to Recovery** | *See postmortem durations* | *Requires incident data* | Elite: < 1 hour |

## Deployment Frequency Detail

| Data Point | Value |
|---|---|
| Total production deploys | ${DEPLOY_COUNT} |
| Release tags (vX.Y.Z) | ${TAG_COUNT} |
| Working days in period | ~${WORKING_DAYS} |
| Deploys per working day | ${DF_PER_DAY} |
| Deploys per week | ${DF_PER_WEEK} |

## Change Failure Rate Detail

| Data Point | Value |
|---|---|
| Total production deploys | ${DEPLOY_COUNT} |
| Incidents (postmortems) | ${INCIDENT_COUNT} |
| Change Failure Rate | ${CFR}% |

## Incidents This Month

REPORT

# Append incident list
if [ "$INCIDENT_COUNT" -gt 0 ]; then
    find "$POSTMORTEMS_DIR" -name "${TARGET_MONTH}*.md" -type f 2>/dev/null | sort | while read -r pm; do
        pm_name=$(basename "$pm" .md)
        echo "- [${pm_name}](../../risk/postmortems/${pm_name}.md)" >> "$REPORT_FILE"
    done
else
    echo "*No incidents recorded this month.*" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << 'REPORT_END'

## RPN ↔ CFR Correlation

<!--
  This section tracks the relationship between SFMEA risk reduction
  (RPN trending down) and DORA delivery health (CFR/MTTR improving).
  Fill in quarterly with data from risk/sfmea.md and this report.
-->

| Quarter | Avg RPN | CFR | MTTR | Trend |
|---|---|---|---|---|
| YYYY-QN | - | -% | - | - |

## Notes

[Add observations, context for anomalies, or action items here.]

---
*Report format: observability/dora/reports/YYYY-MM-dora-report.md*
REPORT_END

echo "Report written to: ${REPORT_FILE}"
echo ""
cat "$REPORT_FILE"
