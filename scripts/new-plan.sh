#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Plan Scaffolding Generator (Bash)
# ==============================================================================
set -e

TITLE="$1"
SLUG="$2"

if [ -z "$TITLE" ]; then
    echo "Usage: ./scripts/new-plan.sh <Title> [slug]"
    exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$SOURCE_DIR/docs/templates/exec-plan.md"
ACTIVE_DIR="$SOURCE_DIR/docs/plans/active"

mkdir -p "$ACTIVE_DIR"

if [ -z "$SLUG" ]; then
    DATE_PREFIX=$(date +%Y%m%d)
    CLEAN_TITLE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
    SLUG="${DATE_PREFIX}-${CLEAN_TITLE}"
fi

PLAN_FILE="$ACTIVE_DIR/${SLUG}.md"
DATE_STR=$(date +%Y-%m-%d)

sed -e "s/# Execution Plan: Title/# Execution Plan: $TITLE/g" \
    -e "s/Date: YYYY-MM-DD/Date: $DATE_STR/g" \
    -e "s/Active | Blocked | Completed/Active/g" \
    "$TEMPLATE" > "$PLAN_FILE"

echo "========================================================"
echo "   NEW DURABLE EXECUTION PLAN CREATED                  "
echo "========================================================"
echo "  Plan Title: $TITLE"
echo "  Location:   docs/plans/active/${SLUG}.md"
echo "========================================================"
