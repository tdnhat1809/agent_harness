#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================================"
echo "   APPLYING AGENT HARNESS TEMPLATE TO THIS PROJECT      "
echo "========================================================"

echo "[*] Target project detected: $PARENT_DIR"
echo "[*] Installing rules, skills, and universal harness..."

chmod +x "$SCRIPT_DIR/install.sh"
"$SCRIPT_DIR/install.sh" "$PARENT_DIR"

echo -e "\n========================================================"
echo "[SUCCESS] Template applied successfully to your project!"
echo "You can now safely remove this 'agent-harness-template' folder."
echo "========================================================"
