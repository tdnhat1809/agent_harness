#!/usr/bin/env bash
# ==============================================================================
# Failure Journal & Lesson Learned Recorder (Bash)
# ==============================================================================
set -e

SYMPTOM="$1"
ROOT_CAUSE="$2"
PREVENTION="$3"
DETAILS="$4"

if [ -z "$SYMPTOM" ] || [ -z "$ROOT_CAUSE" ] || [ -z "$PREVENTION" ]; then
    echo "Usage: ./scripts/record-lesson.sh <Symptom> <RootCause> <Prevention> [Details]"
    exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOURNAL="$SOURCE_DIR/docs/memory/failure-journal.md"

if [ ! -f "$JOURNAL" ]; then
    echo "Error: Failure journal not found at $JOURNAL"
    exit 1
fi

DATE_STR=$(date +%Y-%m-%d)

# Find max ERR-XXX
MAX_ID=0
while IFS= read -r line; do
    if [[ $line =~ ERR-([0-9]+) ]]; then
        NUM=$((10#${BASH_REMATCH[1]}))
        if [ "$NUM" -gt "$MAX_ID" ]; then
            MAX_ID=$NUM
        fi
    fi
done < "$JOURNAL"

NEXT_NUM=$((MAX_ID + 1))
NEXT_ID=$(printf "ERR-%03d" "$NEXT_NUM")

ROW="| \`$NEXT_ID\` | $DATE_STR | $SYMPTOM | $ROOT_CAUSE | $PREVENTION |"

# Append table row and details
sed -i "/|---|---|---|---|---|/a $ROW" "$JOURNAL" 2>/dev/null || echo "$ROW" >> "$JOURNAL"

cat << EOF >> "$JOURNAL"

### \`$NEXT_ID\`: $SYMPTOM
- **Ngày**: $DATE_STR
- **Triệu chứng**: $SYMPTOM
- **Nguyên nhân gốc rễ**: $ROOT_CAUSE
- **Quy tắc bất biến**: $PREVENTION
$([ -n "$DETAILS" ] && echo "- **Chi tiết bổ sung**: $DETAILS")
EOF

echo "✅ [Memory Guard] Successfully recorded lesson $NEXT_ID in docs/memory/failure-journal.md"
