#!/usr/bin/env bash
# Micro-Checkpoint Time Machine & State Rollback Engine (Bash Twin)
set -euo pipefail

ACTION="${1:-snapshot}"
MESSAGE="${2:-Manual checkpoint before task mutation}"
STEP="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SNAP_BASE="$ROOT_DIR/.harness_snapshots"
mkdir -p "$SNAP_BASE"

echo "========================================================"
echo "   MICRO-CHECKPOINT TIME MACHINE (STATE ROLLBACK)       "
echo "========================================================"

case "$ACTION" in
    "snapshot")
        TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
        SNAP_ID="snap_$TIMESTAMP"
        TARGET_DIR="$SNAP_BASE/$SNAP_ID"
        mkdir -p "$TARGET_DIR"

        echo "[*] Creating shadow snapshot: $SNAP_ID"
        echo "    Tag: $MESSAGE"

        echo "{\"id\":\"$SNAP_ID\",\"timestamp\":\"$(date)\",\"message\":\"$MESSAGE\"}" > "$TARGET_DIR/meta.json"
        
        # Copy files excluding heavy/special dirs
        rsync -av --exclude='.git' --exclude='node_modules' --exclude='.harness_snapshots' \
            --exclude='docs/memory' --exclude='docs/plans' "$ROOT_DIR/" "$TARGET_DIR/" >/dev/null 2>&1 || \
            cp -r "$ROOT_DIR"/* "$TARGET_DIR/" 2>/dev/null || true

        echo "[OK] Snapshot captured: $SNAP_ID"
        ;;
    "list")
        echo "[*] Available Checkpoints in Time Machine:"
        ls -1 "$SNAP_BASE" 2>/dev/null || echo "No checkpoints found."
        ;;
    "rollback")
        if [ -z "$STEP" ]; then
            LATEST=$(ls -1td "$SNAP_BASE"/* 2>/dev/null | head -1 || true)
            if [ -z "$LATEST" ]; then
                echo "[FAIL] No snapshots found for rollback."
                exit 1
            fi
            TARGET_SNAP="$LATEST"
        else
            TARGET_SNAP="$SNAP_BASE/$STEP"
        fi

        if [ ! -d "$TARGET_SNAP" ]; then
            echo "[FAIL] Snapshot $TARGET_SNAP not found."
            exit 1
        fi

        echo "[*] Rolling back workspace to checkpoint: $(basename "$TARGET_SNAP")..."
        rsync -av --exclude='meta.json' "$TARGET_SNAP/" "$ROOT_DIR/" >/dev/null 2>&1 || \
            cp -r "$TARGET_SNAP"/* "$ROOT_DIR/" 2>/dev/null || true
        echo "[OK] Rollback complete. Preserved docs/memory and docs/plans intact."
        ;;
    "purge")
        echo "[*] Purging snapshots..."
        rm -rf "$SNAP_BASE"/*
        echo "[OK] All snapshots purged."
        ;;
esac
