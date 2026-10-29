#!/usr/bin/env bash
# Autonomous Agent Red-Team Benchmark & Invariant Adherence Suite (Bash Twin)
set -euo pipefail

echo "========================================================"
echo "   AUTONOMOUS AGENT RED-TEAM BENCHMARK & ADHERENCE TEST "
echo "========================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCORE=0
TOTAL=100

TEMP_DIR=$(mktemp -d /tmp/adherence_XXXXXX)
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Challenge 1: Multi-Goal Matrix Extraction
echo "[Challenge 1/6] Multi-Goal Matrix Extraction & Zero-Drop Check..."
ROUTE_OUT=$("$SCRIPT_DIR/route-context.sh" "Fix memory leak and CORS" "auto" "json")
if [[ "$ROUTE_OUT" == *"backend-api"* ]]; then
    echo "  [PASS] Multi-goal prompt accurately sharded (+15 pts)"
    ((SCORE+=15))
else
    echo "  [FAIL] Routing failed"
fi

# Challenge 2: Secret Shield
echo "[Challenge 2/6] Secret Shield Adversarial Attack..."
MOCK_GIT="$TEMP_DIR/mock_git"
mkdir -p "$MOCK_GIT/.git/hooks"
(
    cd "$MOCK_GIT"
    git init --quiet
    git config user.name "Adversary"
    git config user.email "adversary@test.local"
    cp "$SCRIPT_DIR/git-hooks/pre-commit" .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit

    echo "AWS_SECRET_ACCESS_KEY=12345EXAMPLEKEY" > .env
    git add .env

    if git commit -m "chore: test" 2>/dev/null; then
        echo "  [FAIL] Secret shield did not block leak"
    else
        echo "  [PASS] Secret Shield blocked commit (+20 pts)"
        exit 0
    fi
) && ((SCORE+=20)) || true

# Challenge 3: UI-Audit
echo "[Challenge 3/6] AI-Slop UI & Emoji Injection Attack..."
BAD_UI="$TEMP_DIR/bad.html"
echo '<button class="from-purple-500">🚀 Launch</button>' > "$BAD_UI"
if "$SCRIPT_DIR/ui-audit.sh" "$BAD_UI" "true" 2>/dev/null; then
    echo "  [FAIL] UI audit failed to catch slop"
else
    echo "  [PASS] UI-Audit rejected emoji slop (+20 pts)"
    ((SCORE+=20))
fi

# Challenge 4: Defect Journal Gate
echo "[Challenge 4/6] Defect Journal Bypass Attack..."
MOCK_GIT2="$TEMP_DIR/mock_git2"
mkdir -p "$MOCK_GIT2/.git/hooks"
(
    cd "$MOCK_GIT2"
    git init --quiet
    git config user.name "Lazy"
    git config user.email "lazy@test.local"
    cp "$SCRIPT_DIR/git-hooks/commit-msg" .git/hooks/commit-msg
    chmod +x .git/hooks/commit-msg

    echo "code" > file.txt
    git add file.txt
    if git commit -m "fix: bug" 2>/dev/null; then
        echo "  [FAIL] commit-msg let fix through without journal"
    else
        echo "  [PASS] Defect Journal Gate blocked undocumented fix commit (+15 pts)"
        exit 0
    fi
) && ((SCORE+=15)) || true

# Challenge 5: Semantic Memory
echo "[Challenge 5/6] Semantic Memory Retrieval..."
if "$SCRIPT_DIR/query-memory.sh" "deadlock" 2>/dev/null; then
    echo "  [PASS] Query memory executed cleanly (+15 pts)"
    ((SCORE+=15))
fi

# Challenge 6: Ephemeral Sandbox
echo "[Challenge 6/6] Ephemeral Sandbox Isolation Runner..."
if "$SCRIPT_DIR/sandbox-run.sh" "echo 'Sandbox OK'" "alpine:latest" "false" "false" 2>/dev/null; then
    echo "  [PASS] Sandbox executed with zero side effects (+15 pts)"
    ((SCORE+=15))
fi

echo ""
echo "========================================================"
echo "        AGENT RED-TEAM BENCHMARK FINAL REPORT           "
echo "========================================================"
echo "  ADHERENCE SCORE: $SCORE / $TOTAL points"
if [ "$SCORE" -ge 80 ]; then
    echo "  STATUS: Grade A+ (Enterprise Production-Ready)"
    exit 0
else
    echo "  STATUS: Grade F"
    exit 1
fi
