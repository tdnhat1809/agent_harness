#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Polyglot Test & Verification Engine (Bash)
# Enforces: Invariant 1 (Empirical Metrics) & Strict TDD Validation
# ==============================================================================
set -e

COMMAND="$1"
START_TIME=$(date +%s)

echo "========================================================"
echo "   AI AGENT EMPIRICAL VERIFICATION RUNNER (VERIFY)     "
echo "========================================================"

# Auto-detect test runner if not provided
if [ -z "$COMMAND" ]; then
    if [ -f "pnpm-lock.yaml" ]; then
        COMMAND="pnpm test"
    elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
        COMMAND="bun test"
    elif [ -f "yarn.lock" ]; then
        COMMAND="yarn test"
    elif [ -f "package.json" ]; then
        COMMAND="npm test"
    elif [ -f "uv.lock" ]; then
        COMMAND="uv run pytest"
    elif [ -f "poetry.lock" ]; then
        COMMAND="poetry run pytest"
    elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
        COMMAND="pytest"
    elif [ -f "go.mod" ]; then
        COMMAND="go test -v ./..."
    elif [ -f "Cargo.toml" ]; then
        COMMAND="cargo test"
    elif [ -f "pom.xml" ]; then
        COMMAND="mvn test"
    elif [ -f "build.gradle" ]; then
        COMMAND="./gradlew test"
    elif [ -f "Makefile" ]; then
        COMMAND="make test"
    elif [ -f "scripts/doctor.sh" ]; then
        COMMAND="./scripts/doctor.sh"
    else
        echo "Error: No recognized test runner found in current directory."
        exit 1
    fi
fi

echo -e "\n[*] Executing Test Command: $COMMAND"

set +e
eval "$COMMAND"
EXIT_CODE=$?
set -e

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

DEFECT_MARKER="$SOURCE_DIR/.agents/.defect_active"

echo "========================================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ [VERIFY SUCCESS] Tests PASSED in ${ELAPSED}s (Exit Code: 0)"
    echo "   Empirical evidence verified. Ready for sign-off."

    if [ -f "$DEFECT_MARKER" ]; then
        rm -f "$DEFECT_MARKER" 2>/dev/null || true
        echo ""
        echo "🔔 [HARNESS EXPERIENCE MANDATE] A previously failing test/defect has been resolved!"
        echo "   Invariant 6 & Mandate 5 strictly require persisting the root cause and invariant lesson."
        echo "   👉 RUN NOW: ./scripts/record-lesson.sh \"<symptom>\" \"<root-cause>\" \"<prevention>\""
        echo "   Note: Git 'commit-msg' hook will mechanically REJECT any fix commit without failure-journal.md."
        echo ""
    fi
else
    echo "❌ [VERIFY FAILURE] Tests FAILED in ${ELAPSED}s (Exit Code: $EXIT_CODE)"
    echo "   Strict Invariant Mandate: Fix root cause before claiming completion."
    echo "FAIL|$(date +%s)|$COMMAND" > "$DEFECT_MARKER" 2>/dev/null || true
fi
echo "========================================================"

exit $EXIT_CODE
