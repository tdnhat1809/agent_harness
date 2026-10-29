#!/usr/bin/env bash
# Ephemeral Sandbox & Blast-Radius Isolation Runner (Bash Twin)
set -euo pipefail

COMMAND="${1:-}"
IMAGE="${2:-alpine:latest}"
READONLY="${3:-false}"
SCRUB_SECRETS="${4:-false}"

if [ -z "$COMMAND" ]; then
    echo "Usage: $0 <command> [image] [readonly] [scrub_secrets]"
    exit 1
fi

echo "========================================================"
echo "   EPHEMERAL SANDBOX & BLAST-RADIUS ISOLATION RUNNER    "
echo "========================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "[Engine] Docker detected. Preparing containerized sandbox ($IMAGE)..."
    MOUNT_FLAG="rw"
    if [ "$READONLY" = "true" ]; then
        MOUNT_FLAG="ro"
    fi

    ENV_FLAGS=""
    if [ "$SCRUB_SECRETS" = "true" ]; then
        ENV_FLAGS="-e AWS_ACCESS_KEY_ID= -e AWS_SECRET_ACCESS_KEY= -e GITHUB_TOKEN= -e GH_TOKEN="
    fi

    echo "[*] Executing inside container: $COMMAND"
    docker run --rm \
        -v "$REPO_ROOT:/workspace:$MOUNT_FLAG" \
        -w /workspace \
        $ENV_FLAGS \
        "$IMAGE" \
        sh -c "$COMMAND"
    exit $?
else
    echo "[Engine] Docker not detected. Utilizing Ephemeral Snapshot Isolation..."
    TEMP_SANDBOX=$(mktemp -d /tmp/sandbox_XXXXXX)
    
    cleanup() {
        echo "[*] Destroying ephemeral sandbox: $TEMP_SANDBOX"
        rm -rf "$TEMP_SANDBOX"
    }
    trap cleanup EXIT

    echo "[*] Creating ephemeral snapshot in: $TEMP_SANDBOX"
    cp -r "$REPO_ROOT"/* "$TEMP_SANDBOX/" 2>/dev/null || true

    echo "[*] Executing in sandbox: $COMMAND"
    (
        cd "$TEMP_SANDBOX"
        if [ "$SCRUB_SECRETS" = "true" ]; then
            unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY GITHUB_TOKEN GH_TOKEN OPENAI_API_KEY ANTHROPIC_API_KEY
        fi
        eval "$COMMAND"
    )
    exit $?
fi
