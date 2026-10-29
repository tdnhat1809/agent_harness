#!/usr/bin/env bash
# Agent Harness Semantic Memory & Precedent Indexer (Bash Twin)
set -euo pipefail

QUERY="${1:-}"
TOP="${2:-5}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [top]"
    exit 1
fi

echo "========================================================"
echo "   SEMANTIC MEMORY & PRECEDENT RETRIEVAL (BM25/N-GRAM) "
echo "========================================================"
echo "[*] Query: $QUERY"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

QUERY_LOWER=$(echo "$QUERY" | tr '[:upper:]' '[:lower:]')
JOURNAL="$ROOT_DIR/docs/memory/failure-journal.md"

MATCH_COUNT=0
if [ -f "$JOURNAL" ]; then
    while IFS= read -r line; do
        if [[ "$line" =~ ^\|[[:space:]]*(ERR-[0-9]+) ]]; then
            id="${BASH_REMATCH[1]}"
            line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
            
            # Check terms
            matched=false
            for term in $QUERY_LOWER; do
                if [[ "$line_lower" == *"$term"* ]]; then
                    matched=true
                    break
                fi
            done

            if [ "$matched" = true ]; then
                ((MATCH_COUNT++))
                echo "[Failure Journal] $id"
                echo "  Line: $line"
                echo ""
                if [ "$MATCH_COUNT" -ge "$TOP" ]; then
                    break
                fi
            fi
        fi
    done < "$JOURNAL"
fi

if [ "$MATCH_COUNT" -eq 0 ]; then
    echo "[*] No matching memory entries found for: '$QUERY'"
fi
