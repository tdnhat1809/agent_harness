#!/usr/bin/env bash
# ==============================================================================
# Architecture Decision Record (ADR) Generator (Bash)
# ==============================================================================
set -e

TITLE="$1"

if [ -z "$TITLE" ]; then
    echo "Usage: ./scripts/new-adr.sh <Title>"
    exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DECISIONS_DIR="$SOURCE_DIR/docs/decisions"

mkdir -p "$DECISIONS_DIR"

# Determine next number
MAX_NUM=0
for f in "$DECISIONS_DIR"/*.md; do
    [ -e "$f" ] || continue
    fname=$(basename "$f")
    if [[ $fname =~ ^([0-9]{4})- ]]; then
        num=$((10#${BASH_REMATCH[1]}))
        if [ "$num" -gt "$MAX_NUM" ]; then
            MAX_NUM=$num
        fi
    fi
done

NEXT_NUM=$((MAX_NUM + 1))
FORMATTED_NUM=$(printf "%04d" "$NEXT_NUM")

# Slugify title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')
FILE_NAME="${FORMATTED_NUM}-${SLUG}.md"
FILE_PATH="$DECISIONS_DIR/$FILE_NAME"
TODAY=$(date +%Y-%m-%d)

cat << EOF > "$FILE_PATH"
# $FORMATTED_NUM $TITLE

Date: $TODAY

## Status

Proposed

## Context

What problem, constraint, or ambiguity forced this decision?

## Decision

What did we decide?

## Alternatives Considered

1. Alternative A
2. Alternative B

## Consequences

Positive:

- Benefit 1

Tradeoffs:

- Tradeoff 1

## Follow-Up

- Action item 1
EOF

echo "✅ [ADR Generator] Created new Architecture Decision Record:"
echo "   $FILE_PATH"
