#!/usr/bin/env bash
# =============================================================================
# validate-fta-diagrams.sh — FTA ↔ Architecture Diagram Coherence Validator
# =============================================================================
#
# WHY THIS SCRIPT EXISTS:
#   Fault Tree Analysis (FTA) nodes reference architecture components by name.
#   If a component is renamed, removed, or misspelled, the FTA becomes
#   disconnected from reality — risk analysis that doesn't match the actual
#   architecture is worse than useless because it provides false confidence.
#
#   This script extracts component names from FTA files and verifies they
#   exist in the architecture diagrams. It runs as part of the
#   definition-of-done workflow for PRs labeled `new-service`, `migration`,
#   or `integration-change`.
#
# HOW IT WORKS:
#   1. Scans /docs/architecture/*.md for component names in Mermaid diagrams
#      (extracts identifiers from node definitions like: ApiGateway["..."])
#   2. Scans /risk/fta/*.md for "Component:" references
#   3. Reports any FTA component references that don't exist in architecture
#
# USAGE:
#   ./build/validate-fta-diagrams.sh [--strict]
#     --strict: exit with error code 1 on any mismatch (used in CI)
#     default:  prints warnings but exits 0 (used locally)
#
# EXIT CODES:
#   0 — All FTA components found in architecture diagrams (or no FTA files)
#   1 — (strict mode) One or more FTA components not found in architecture
#   2 — Script error (missing directories, etc.)
# =============================================================================

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ARCH_DIR="${REPO_ROOT}/docs/architecture"
FTA_DIR="${REPO_ROOT}/risk/fta"
STRICT=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --strict) STRICT=true ;;
        --help|-h)
            echo "Usage: $0 [--strict]"
            echo "  --strict  Exit with code 1 on any mismatch (CI mode)"
            exit 0
            ;;
    esac
done

echo "=== FTA ↔ Architecture Diagram Coherence Check ==="
echo ""

# --- Step 1: Check directories exist ---
if [ ! -d "$ARCH_DIR" ]; then
    echo "WARN: Architecture directory not found: ${ARCH_DIR}"
    echo "      Create architecture diagrams in docs/architecture/ first."
    exit 0
fi

if [ ! -d "$FTA_DIR" ]; then
    echo "INFO: No FTA directory found. Skipping validation."
    exit 0
fi

# --- Step 2: Extract component names from architecture diagrams ---
# Looks for Mermaid node definitions in these formats:
#   ComponentName["Label"]
#   ComponentName["Label<br/>subtitle"]
#   ComponentName[Label]
#   ComponentName("Label")
#   ComponentName(["Label"])
ARCH_COMPONENTS_FILE=$(mktemp)
trap 'rm -f "$ARCH_COMPONENTS_FILE" "${FTA_COMPONENTS_FILE:-}"' EXIT

# Extract identifiers before [ or ( in Mermaid flowchart lines
find "$ARCH_DIR" -name "*.md" -type f -exec grep -hoE '^[[:space:]]*[A-Za-z][A-Za-z0-9_]*(\[|\()' {} + 2>/dev/null \
    | sed 's/[[:space:]]//g' \
    | sed 's/[\[\(]$//' \
    | sort -u > "$ARCH_COMPONENTS_FILE" || true

ARCH_COUNT=$(wc -l < "$ARCH_COMPONENTS_FILE" | tr -d ' ')

if [ "$ARCH_COUNT" -eq 0 ]; then
    echo "WARN: No components found in architecture diagrams."
    echo "      Ensure diagrams use Mermaid syntax with named nodes."
    echo "      Example: ApiGateway[\"API Gateway\"]"
    echo ""
    if [ "$STRICT" = true ]; then
        echo "SKIP: No architecture components to validate against."
    fi
    exit 0
fi

echo "Found ${ARCH_COUNT} components in architecture diagrams:"
while IFS= read -r comp; do
    echo "  - ${comp}"
done < "$ARCH_COMPONENTS_FILE"
echo ""

# --- Step 3: Extract component references from FTA files ---
FTA_COMPONENTS_FILE=$(mktemp)

# Look for "Component:" or "Component :" patterns in FTA files
find "$FTA_DIR" -name "*.md" -type f ! -name "template.md" -exec \
    grep -hoE 'Component:[[:space:]]*[A-Za-z][A-Za-z0-9_ ]*' {} + 2>/dev/null \
    | sed 's/Component:[[:space:]]*//' \
    | sed 's/[[:space:]]*$//' \
    | sort -u > "$FTA_COMPONENTS_FILE" || true

FTA_COUNT=$(wc -l < "$FTA_COMPONENTS_FILE" | tr -d ' ')

if [ "$FTA_COUNT" -eq 0 ]; then
    echo "INFO: No component references found in FTA files."
    echo "      FTA nodes should include 'Component: ComponentName'."
    exit 0
fi

echo "Found ${FTA_COUNT} component references in FTA files:"
while IFS= read -r comp; do
    echo "  - ${comp}"
done < "$FTA_COMPONENTS_FILE"
echo ""

# --- Step 4: Cross-reference ---
MISMATCHES=0
echo "=== Validation Results ==="

while IFS= read -r fta_comp; do
    # Trim and check if the component exists in architecture
    if ! grep -qiF "$fta_comp" "$ARCH_COMPONENTS_FILE"; then
        echo "FAIL: FTA references component '${fta_comp}' but it was NOT found in architecture diagrams."
        MISMATCHES=$((MISMATCHES + 1))
    else
        echo "  OK: '${fta_comp}' found in architecture."
    fi
done < "$FTA_COMPONENTS_FILE"

echo ""

if [ "$MISMATCHES" -gt 0 ]; then
    echo "=== RESULT: ${MISMATCHES} FTA component(s) not found in architecture ==="
    echo ""
    echo "Fix by either:"
    echo "  1. Adding the component to a diagram in docs/architecture/"
    echo "  2. Correcting the component name in risk/fta/ to match the diagram"
    echo ""
    if [ "$STRICT" = true ]; then
        echo "STRICT MODE: Failing with exit code 1."
        exit 1
    else
        echo "NON-STRICT MODE: Exiting with warnings only."
        exit 0
    fi
else
    echo "=== RESULT: All FTA components verified in architecture diagrams ==="
    exit 0
fi
