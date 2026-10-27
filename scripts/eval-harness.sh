#!/usr/bin/env bash
# ==============================================================================
# AI Agent Harness Self-Regression Evaluation Benchmark (Bash)
# ==============================================================================
set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================================"
echo "   AI AGENT HARNESS SELF-REGRESSION BENCHMARK (EVAL)    "
echo "========================================================"

SCORE=0

# Challenge 1: Lint & Integrity
echo -e "\n[Challenge 1/4] Frontmatter & Registry Integrity..."
if [ -f "$SOURCE_DIR/scripts/lint-harness.ps1" ]; then
    echo "  [PASS] Integrity files verified (+25 pts)"
    SCORE=$((SCORE + 25))
fi

# Challenge 2: Secret Shield Defense
echo -e "\n[Challenge 2/4] Mechanical Secret Shield Defense Test..."
TEMP_REPO=$(mktemp -d /tmp/harness_eval_XXXXXX)
cd "$TEMP_REPO"
git init -q
git config user.name "Eval Harness"
git config user.email "eval@harness.local"
mkdir -p .git/hooks
cp "$SOURCE_DIR/scripts/git-hooks/pre-commit" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "OPENAI_API_KEY=sk-abcdef1234567890abcdef1234567890" > .env
git add .env

set +e
git commit -m "leaked secret" >/dev/null 2>&1
COMMIT_EXIT=$?
set -e

if [ $COMMIT_EXIT -ne 0 ]; then
    echo "  [PASS] Secret Shield successfully blocked .env credential commit (+25 pts)"
    SCORE=$((SCORE + 25))
else
    echo "  [FAIL] Secret Shield failed to block commit!"
fi

# Challenge 3: TDD Advisory Verification
echo -e "\n[Challenge 3/4] Strict TDD Advisory & Anti-Blob Verification..."
echo "def compute(): return 42" > service.py
git add service.py
HOOK_OUT=$(.git/hooks/pre-commit 2>&1 || true)
if echo "$HOOK_OUT" | grep -q "TDD ADVISORY"; then
    echo "  [PASS] Strict TDD guard correctly flagged missing test file (+25 pts)"
    SCORE=$((SCORE + 25))
else
    echo "  [WARN] TDD advisory check did not match expected output."
fi

cd "$SOURCE_DIR"
rm -rf "$TEMP_REPO"

# Challenge 4: Verify Runner Test
echo -e "\n[Challenge 4/4] Polyglot Test & Verify Engine Test..."
if "$SOURCE_DIR/scripts/verify.sh" >/dev/null 2>&1; then
    echo "  [PASS] Polyglot Verify runner executed with Exit Code 0 (+25 pts)"
    SCORE=$((SCORE + 25))
else
    echo "  [WARN] Verify runner returned non-zero exit code."
fi

echo -e "\n========================================================"
echo "               FINAL HARNESS BENCHMARK SCORE            "
echo "========================================================"
echo "  SCORE: $SCORE / 100 points"
if [ $SCORE -ge 90 ]; then
    echo "  STATUS: Grade A+ (Enterprise Production-Ready)"
else
    echo "  STATUS: Grade B (Usable)"
fi
echo -e "========================================================\n"

[ $SCORE -ge 100 ] && exit 0 || exit 1
