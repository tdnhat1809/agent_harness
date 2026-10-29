#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Token-Efficient Memory & Knowledge Query Engine (Bash)
# ==============================================================================
set -e

QUERY="$1"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$QUERY" ]; then
    echo "Usage: ./scripts/query-memory.sh <search_query>"
    exit 1
fi

echo "========================================================"
echo "   AI AGENT MEMORY & KNOWLEDGE RETRIEVAL (QUERY)       "
echo "========================================================"
echo "[*] Searching for: \"$QUERY\""
echo ""

JOURNAL="$SOURCE_DIR/docs/memory/failure-journal.md"

if [ -f "$JOURNAL" ]; then
    echo "Matches in Failure Journal:"
    grep -i -E "\|.*`ERR-[0-9]+`.*$QUERY" "$JOURNAL" || grep -i "$QUERY" "$JOURNAL" | head -n 5 || echo "  No direct matches."
fi

echo ""
echo "========================================================"
