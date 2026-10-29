#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Mutation Testing Engine (Bash)
# Enforces: Invariant 1 (Empirical Truth) & Anti-Hollow Testing Protocol
# ==============================================================================
set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$1"
TEST_CMD="${2:-"$SOURCE_DIR/scripts/verify.sh"}"

echo "========================================================"
echo "   AI AGENT MUTATION TESTING ENGINE (ANTI-HOLLOW TEST) "
echo "========================================================"

if [ -z "$FILE" ]; then
    FILE=$(git diff --name-only | grep -E '\.(py|ts|js|go|rs|sh)$' | grep -v 'test' | head -n 1 || true)
fi

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Usage: ./scripts/mutation-test.sh <file> [test_command]"
    exit 1
fi

echo "[*] Target Source File: $FILE"
echo "[*] Test Command: $TEST_CMD"

# 1. Baseline Test
echo -e "\n[1/3] Running Baseline Tests..."
if ! eval "$TEST_CMD" >/dev/null 2>&1; then
    echo "❌ [MUTATION ABORT] Baseline tests are currently failing!"
    exit 1
fi
echo "  [OK] Baseline tests passed cleanly."

# 2. Mutate and Test
echo -e "\n[2/3] Evaluating Mutants..."
BACKUP_FILE="${FILE}.mutation.bak"
cp -f "$FILE" "$BACKUP_FILE"

KILLED=0
TOTAL=0

restore_file() {
    cp -f "$BACKUP_FILE" "$FILE"
    rm -f "$BACKUP_FILE"
}
trap restore_file EXIT

# Mutant 1: Boolean flip
if grep -q "true" "$FILE" 2>/dev/null; then
    TOTAL=$((TOTAL + 1))
    sed -i 's/\btrue\b/false/g' "$FILE"
    if eval "$TEST_CMD" >/dev/null 2>&1; then
        echo "  -> Mutant #$TOTAL (true -> false): SURVIVED ❌"
    else
        echo "  -> Mutant #$TOTAL (true -> false): KILLED ✅"
        KILLED=$((KILLED + 1))
    fi
    cp -f "$BACKUP_FILE" "$FILE"
fi

# Mutant 2: Operator flip
if grep -q " == " "$FILE" 2>/dev/null; then
    TOTAL=$((TOTAL + 1))
    sed -i 's/ == / != /g' "$FILE"
    if eval "$TEST_CMD" >/dev/null 2>&1; then
        echo "  -> Mutant #$TOTAL (== -> !=): SURVIVED ❌"
    else
        echo "  -> Mutant #$TOTAL (== -> !=): KILLED ✅"
        KILLED=$((KILLED + 1))
    fi
    cp -f "$BACKUP_FILE" "$FILE"
fi

echo -e "\n========================================================"
echo "               MUTATION TESTING REPORT                  "
echo "========================================================"
echo "  Target File:     $FILE"
echo "  Mutants Tested:  $TOTAL"
echo "  Mutants Killed:  $KILLED"
echo "========================================================"

exit 0
