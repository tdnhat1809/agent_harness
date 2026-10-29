#!/usr/bin/env bash
# Visual UI & Design System Auditor (Bash Twin)
set -euo pipefail

TARGET="${1:-.}"
STRICT="${2:-false}"

echo "========================================================"
echo "   VISUAL UI & DESIGN SYSTEM AUDITOR (ANTI-AI SLOP)    "
echo "========================================================"

EMOJI_PATTERN="[🚀🛡️🌟📊🔴🟢🤖🔄📝⚡👤📂🛠️🧠🧭📄🛑💡🔥🎉✨]"
PURPLE_GRADIENT_PATTERN="(from-purple-|to-indigo-|from-violet-|to-purple-)"

VIOLATIONS=0
FILES_SCANNED=0

# Find files
while IFS= read -r file; do
    ((FILES_SCANNED++))
    line_num=0
    while IFS= read -r line || [ -n "$line" ]; do
        ((line_num++))
        
        # Check 1: Emoji
        if [[ "$line" =~ $EMOJI_PATTERN ]]; then
            ((VIOLATIONS++))
            echo "[Critical] $file:$line_num - AI-SLOP-EMOJI"
            echo "  Issue: Raw emoji detected in UI element. Replace with SVG icon."
            echo "  Snippet: ${line:0:100}"
        fi

        # Check 2: Purple gradient
        if [[ "$line" =~ $PURPLE_GRADIENT_PATTERN ]]; then
            ((VIOLATIONS++))
            echo "[High] $file:$line_num - AI-SLOP-GRADIENT"
            echo "  Issue: Cliche AI purple gradient detected. Use Neutral Zinc/Slate design tokens."
            echo "  Snippet: ${line:0:100}"
        fi

        # Check 3: Missing alt
        if [[ "$line" =~ \<img\  ]] && [[ ! "$line" =~ alt= ]]; then
            ((VIOLATIONS++))
            echo "[Medium] $file:$line_num - A11Y-MISSING-ALT"
            echo "  Issue: Image tag missing alt attribute."
            echo "  Snippet: ${line:0:100}"
        fi
    done < "$file"
done < <(find "$TARGET" -type f \( -name "*.html" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" 2>/dev/null || true)

echo ""
echo "--- Audit Results ---"
echo "Files Scanned: $FILES_SCANNED"
echo "Violations Found: $VIOLATIONS"

if [ "$VIOLATIONS" -gt 0 ]; then
    if [ "$STRICT" = "true" ] || [ "$STRICT" = "-Strict" ]; then
        echo "[FAIL] UI Audit failed under strict mode."
        exit 1
    else
        echo "[WARN] UI Audit detected non-compliant elements."
        exit 0
    fi
else
    echo "[PASS] Zero AI slop detected in UI components."
    exit 0
fi
