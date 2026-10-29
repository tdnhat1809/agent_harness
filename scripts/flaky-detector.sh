#!/usr/bin/env bash
# Flaky Test Isolator & Bisection Engine (Bash Twin)
set -euo pipefail

COMMAND="${1:-}"
ITERATIONS="${2:-5}"
QUARANTINE="${3:-false}"

if [ -z "$COMMAND" ]; then
    echo "Usage: $0 <test_command> [iterations] [quarantine]"
    exit 1
fi

echo "========================================================"
echo "   FLAKY TEST ISOLATOR & BISECTION ENGINE               "
echo "========================================================"
echo "[*] Target Command: $COMMAND"
echo "[*] Iterations:     $ITERATIONS"

PASSED=0
FAILED=0

for ((i=1; i<=ITERATIONS; i++)); do
    echo -n "  [Run $i/$ITERATIONS] Executing... "
    if eval "$COMMAND" >/dev/null 2>&1; then
        ((PASSED++))
        echo "PASS"
    else
        ((FAILED++))
        echo "FAIL"
    fi
done

echo ""
echo "--- Execution Summary ---"
echo "Total Runs:  $ITERATIONS"
echo "Passed:      $PASSED"
echo "Failed:      $FAILED"

if [ "$PASSED" -eq "$ITERATIONS" ]; then
    echo "[RESULT] CONSISTENT GREEN (100% Pass Rate). Deterministic and stable."
    exit 0
elif [ "$FAILED" -eq "$ITERATIONS" ]; then
    echo "[RESULT] CONSISTENT RED (100% Fail Rate). True defect detected."
    exit 1
else
    FLAKE_PCT=$(( (FAILED * 100) / ITERATIONS ))
    echo "[RESULT] FLAKY TEST DETECTED (Flake Rate: ${FLAKE_PCT}%)."
    
    if [ "$QUARANTINE" = "true" ] || [ "$QUARANTINE" = "-Quarantine" ]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        QFILE="$SCRIPT_DIR/../docs/memory/quarantined-tests.md"
        mkdir -p "$(dirname "$QFILE")"
        if [ ! -f "$QFILE" ]; then
            echo "# Quarantined Flaky Tests Register" > "$QFILE"
            echo "" >> "$QFILE"
            echo "| Quarantined Date | Test Command | Flake Rate | Iterations | Status | Action Required |" >> "$QFILE"
            echo "|---|---|---|---|---|---|" >> "$QFILE"
        fi
        DATE_STR=$(date +"%Y-%m-%d %H:%M:%S")
        echo "| $DATE_STR | \`$COMMAND\` | ${FLAKE_PCT}% | $ITERATIONS | QUARANTINED | Isolate shared state / mock timer |" >> "$QFILE"
        echo "  [QUARANTINED] Recorded into docs/memory/quarantined-tests.md"
    fi
    exit 2
fi
