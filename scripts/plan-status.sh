#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Plan Status & Kanban Progress Tracker (Bash)
# ==============================================================================
set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_DIR="$SOURCE_DIR/docs/plans/active"

echo "========================================================"
echo "   AI AGENT ACTIVE PLANS & KANBAN STATUS TRACKER       "
echo "========================================================"

if [ ! -d "$ACTIVE_DIR" ] || [ -z "$(ls -A "$ACTIVE_DIR"/*.md 2>/dev/null)" ]; then
    echo "ℹ️  No active durable plans in docs/plans/active/"
    echo "========================================================"
    exit 0
fi

for PLAN in "$ACTIVE_DIR"/*.md; do
    [ -e "$PLAN" ] || continue
    FNAME=$(basename "$PLAN")
    [ "$FNAME" == ".gitkeep" ] && continue

    TITLE=$(grep -m 1 "^# Execution Plan:" "$PLAN" | sed 's/# Execution Plan: //g' || echo "$FNAME")
    DONE=$(grep -c -- "- \[x\]" "$PLAN" || true)
    PENDING=$(grep -c -- "- \[ \]" "$PLAN" || true)
    TOTAL=$((DONE + PENDING))

    PCT=0
    if [ $TOTAL -gt 0 ]; then
        PCT=$(( (DONE * 100) / TOTAL ))
    fi

    echo ""
    echo "📄 Plan: $TITLE ($FNAME)"
    echo "   Progress: $PCT% ($DONE / $TOTAL tasks done)"
done

echo "========================================================"
