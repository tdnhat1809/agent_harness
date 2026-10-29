#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Plan Archival & Lifecycle Closer (Bash)
# ==============================================================================
set -e

PLAN_NAME="$1"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_DIR="$SOURCE_DIR/docs/plans/active"
COMPLETED_DIR="$SOURCE_DIR/docs/plans/completed"

mkdir -p "$COMPLETED_DIR"

if [ -z "$PLAN_NAME" ]; then
    PLANS=($(ls "$ACTIVE_DIR"/*.md 2>/dev/null | grep -v ".gitkeep" || true))
    if [ ${#PLANS[@]} -eq 1 ]; then
        PLAN_FILE="${PLANS[0]}"
    else
        echo "Please specify plan name to archive."
        exit 1
    fi
else
    PLAN_FILE="$ACTIVE_DIR/$PLAN_NAME"
fi

if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file not found at $PLAN_FILE"
    exit 1
fi

BASENAME=$(basename "$PLAN_FILE")
DEST="$COMPLETED_DIR/$BASENAME"
DATE_STR=$(date "+%Y-%m-%d %H:%M:%S")

sed -i "s/## Status/## Status\n\nCompleted ($DATE_STR)/g" "$PLAN_FILE"
mv "$PLAN_FILE" "$DEST"

echo "========================================================"
echo "   PLAN SUCCESSFULLY COMPLETED & ARCHIVED               "
echo "========================================================"
echo "  Archived: docs/plans/completed/$BASENAME"
echo "========================================================"
