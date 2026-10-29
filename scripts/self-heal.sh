#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Self-Healing & Workspace Recovery Protocol (Bash)
# ==============================================================================
set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTION="${1:---status}"

echo "========================================================"
echo "   AI AGENT WORKSPACE SELF-HEAL & RECOVERY ENGINE      "
echo "========================================================"

case "$ACTION" in
    --snapshot|-s)
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        MSG="harness-snapshot-$TIMESTAMP"
        STASH_ID=$(git stash create "$MSG" || true)
        if [ -n "$STASH_ID" ]; then
            git stash store -m "$MSG" "$STASH_ID"
            echo "  [OK] Workspace snapshot stored: $MSG"
        else
            echo "  [INFO] Working tree is clean. Current HEAD is the snapshot."
        fi
        ;;
    --rollback|-r)
        echo "  [!] Rolling back tracked files while preserving docs/..."
        JOURNAL_BAK=""
        if [ -f "$SOURCE_DIR/docs/memory/failure-journal.md" ]; then
            JOURNAL_BAK=$(cat "$SOURCE_DIR/docs/memory/failure-journal.md")
        fi
        git checkout -- .
        git clean -fd -e docs/ -e .gemini/
        if [ -n "$JOURNAL_BAK" ]; then
            echo "$JOURNAL_BAK" > "$SOURCE_DIR/docs/memory/failure-journal.md"
        fi
        echo "  [OK] Rollback complete. Memory preserved."
        ;;
    --clean|-c)
        echo "  [*] Cleaning caches and temporary files..."
        find "$SOURCE_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
        find "$SOURCE_DIR" -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
        rm -f "$SOURCE_DIR/.agents/.defect_active" 2>/dev/null || true
        echo "  [OK] Cache cleanup complete."
        ;;
    *)
        echo "  [*] Current Git Status:"
        git status --short
        ;;
esac

echo "========================================================"
