#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Autonomous Package & GitHub Inspector (Bash)
# ==============================================================================
set -e

ACTION="$1"
TARGET="$2"

echo "========================================================"
echo "   AI AGENT PACKAGE & REPO RESEARCH INSPECTOR          "
echo "========================================================"

if [ -z "$ACTION" ] || [ -z "$TARGET" ]; then
    echo "Usage: ./scripts/inspect-package.sh [--npm|--pypi|--github|--search] <name>"
    exit 1
fi

case "$ACTION" in
    --npm)
        echo "[*] Querying NPM Registry for $TARGET..."
        curl -s "https://registry.npmjs.org/$TARGET/latest" | grep -o -E '"name":"[^"]+"|"version":"[^"]+"|"description":"[^"]+"' | head -n 3
        ;;
    --pypi)
        echo "[*] Querying PyPI Registry for $TARGET..."
        curl -s "https://pypi.org/pypi/$TARGET/json" | grep -o -E '"version":"[^"]+"|"summary":"[^"]+"' | head -n 2
        ;;
    --github)
        echo "[*] Querying GitHub for $TARGET..."
        if command -v gh >/dev/null 2>&1; then
            gh repo view "$TARGET" | head -n 15
        else
            curl -s "https://api.github.com/repos/$TARGET" | grep -o -E '"full_name":"[^"]+"|"stargazers_count":[0-9]+|"description":"[^"]+"' | head -n 3
        fi
        ;;
    --search)
        echo "[*] Searching GitHub for $TARGET..."
        if command -v gh >/dev/null 2>&1; then
            gh search repos "$TARGET" --limit 5 --sort stars
        else
            echo "GitHub CLI (gh) not installed."
        fi
        ;;
    *)
        echo "Unknown option: $ACTION"
        ;;
esac

echo "========================================================"
