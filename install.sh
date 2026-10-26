#!/usr/bin/env bash
# ==============================================================================
# Universal AI Agent Harness & Skills Framework Installer for Linux / macOS
# Supports: Antigravity IDE, Claude CLI (Claude Code), Codex, OpenCode, Cursor, Windsurf, Copilot
# ==============================================================================
set -e

TARGET_DIR="$1"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================"
echo "   UNIVERSAL AI AGENT HARNESS & SKILLS FRAMEWORK       "
echo "========================================================"

if [ -z "$TARGET_DIR" ]; then
    if [ -d "$SOURCE_DIR/../.git" ] || [ -f "$SOURCE_DIR/../package.json" ] || [ -f "$SOURCE_DIR/../go.mod" ] || [ -f "$SOURCE_DIR/../Cargo.toml" ] || [ -f "$SOURCE_DIR/../pyproject.toml" ]; then
        TARGET_DIR="$(cd "$SOURCE_DIR/.." && pwd)"
        echo "[Auto-Detected] Installing into parent project root: $TARGET_DIR"
    else
        TARGET_DIR="$(pwd)"
    fi
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory does not exist: $TARGET_DIR"
    exit 1
fi

echo -e "\n[*] Installing into: $TARGET_DIR"

# 1. Create target subdirectories
mkdir -p "$TARGET_DIR/.agents/rules" \
         "$TARGET_DIR/.agents/plugins" \
         "$TARGET_DIR/.agents/skills" \
         "$TARGET_DIR/.agents/roles" \
         "$TARGET_DIR/.agents/workflows" \
         "$TARGET_DIR/.claude/commands" \
         "$TARGET_DIR/.cursor/rules" \
         "$TARGET_DIR/.github/workflows" \
         "$TARGET_DIR/docs/plans/active" \
         "$TARGET_DIR/docs/plans/completed" \
         "$TARGET_DIR/docs/decisions" \
         "$TARGET_DIR/docs/patterns" \
         "$TARGET_DIR/docs/templates" \
         "$TARGET_DIR/docs/runbooks" \
         "$TARGET_DIR/scripts"

# 2. Copy .agents directory
echo "[+] Copying .agents (hooks, mcp, rules, plugins, skills, roles, workflows)..."
cp -f "$SOURCE_DIR/.agents/hooks.json" "$TARGET_DIR/.agents/hooks.json"
cp -f "$SOURCE_DIR/.agents/mcp_config.json" "$TARGET_DIR/.agents/mcp_config.json"
[ -f "$SOURCE_DIR/.agents/mcp_catalog.json" ] && cp -f "$SOURCE_DIR/.agents/mcp_catalog.json" "$TARGET_DIR/.agents/mcp_catalog.json"
cp -rf "$SOURCE_DIR/.agents/rules/"* "$TARGET_DIR/.agents/rules/"
cp -rf "$SOURCE_DIR/.agents/plugins/"* "$TARGET_DIR/.agents/plugins/"
cp -rf "$SOURCE_DIR/.agents/skills/"* "$TARGET_DIR/.agents/skills/"
[ -d "$SOURCE_DIR/.agents/roles" ] && cp -rf "$SOURCE_DIR/.agents/roles/"* "$TARGET_DIR/.agents/roles/"
[ -d "$SOURCE_DIR/.agents/workflows" ] && cp -rf "$SOURCE_DIR/.agents/workflows/"* "$TARGET_DIR/.agents/workflows/"

# 3. Copy .claude commands
if [ -d "$SOURCE_DIR/.claude/commands" ]; then
    echo "[+] Copying Claude Code slash commands (.claude/commands)..."
    cp -rf "$SOURCE_DIR/.claude/commands/"* "$TARGET_DIR/.claude/commands/"
fi

# 4. Copy docs directory
echo "[+] Copying docs (HARNESS, INVARIANTS, WORKFLOW, patterns, templates, decisions, scratchpad)..."
cp -f "$SOURCE_DIR/docs/HARNESS.md" "$TARGET_DIR/docs/HARNESS.md"
[ -f "$SOURCE_DIR/docs/INVARIANTS.md" ] && cp -f "$SOURCE_DIR/docs/INVARIANTS.md" "$TARGET_DIR/docs/INVARIANTS.md"
cp -f "$SOURCE_DIR/docs/WORKFLOW.md" "$TARGET_DIR/docs/WORKFLOW.md"
[ -f "$SOURCE_DIR/docs/scratchpad.md" ] && cp -f "$SOURCE_DIR/docs/scratchpad.md" "$TARGET_DIR/docs/scratchpad.md"
cp -rf "$SOURCE_DIR/docs/patterns/"* "$TARGET_DIR/docs/patterns/"
cp -rf "$SOURCE_DIR/docs/templates/"* "$TARGET_DIR/docs/templates/"
[ -d "$SOURCE_DIR/docs/decisions" ] && cp -rf "$SOURCE_DIR/docs/decisions/"* "$TARGET_DIR/docs/decisions/"

# 5. Copy Cursor .mdc rules and scripts
if [ -d "$SOURCE_DIR/.cursor/rules" ]; then
    cp -rf "$SOURCE_DIR/.cursor/rules/"* "$TARGET_DIR/.cursor/rules/"
fi
if [ -d "$SOURCE_DIR/scripts" ]; then
    cp -rf "$SOURCE_DIR/scripts/"* "$TARGET_DIR/scripts/"
fi

# Keep folders in git
touch "$TARGET_DIR/docs/plans/active/.gitkeep"
touch "$TARGET_DIR/docs/plans/completed/.gitkeep"
touch "$TARGET_DIR/docs/runbooks/.gitkeep"

# Helper to merge or create
merge_or_create() {
    local src="$1"
    local dst="$2"
    local label="$3"
    if [ ! -f "$dst" ]; then
        echo "[+] Creating new $label..."
        cp "$src" "$dst"
    else
        if ! grep -q "<!-- HARNESS:BEGIN -->" "$dst"; then
            echo "[+] Appending Harness block to existing $label..."
            echo -e "\n" >> "$dst"
            sed -n '/<!-- HARNESS:BEGIN -->/,/<!-- HARNESS:END -->/p' "$src" >> "$dst"
            echo "    -> $label merged safely!"
        else
            echo "[i] $label already contains Harness block. Skipping."
        fi
    fi
}

# 5. Universal Harness Entrypoints
merge_or_create "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md"
merge_or_create "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md (Claude Code)"
merge_or_create "$SOURCE_DIR/CODEX.md" "$TARGET_DIR/CODEX.md" "CODEX.md (Codex)"
merge_or_create "$SOURCE_DIR/OPENCODE.md" "$TARGET_DIR/OPENCODE.md" "OPENCODE.md (OpenCode)"
[ -f "$SOURCE_DIR/GEMINI.md" ] && merge_or_create "$SOURCE_DIR/GEMINI.md" "$TARGET_DIR/GEMINI.md" "GEMINI.md (Antigravity / Gemini)"

# 6. IDE Rules & Ignore Files
[ ! -f "$TARGET_DIR/.cursorrules" ] && cp "$SOURCE_DIR/.cursorrules" "$TARGET_DIR/.cursorrules"
[ ! -f "$TARGET_DIR/.windsurfrules" ] && cp "$SOURCE_DIR/.windsurfrules" "$TARGET_DIR/.windsurfrules"
[ ! -f "$TARGET_DIR/.cursorignore" ] && cp "$SOURCE_DIR/.cursorignore" "$TARGET_DIR/.cursorignore"
[ ! -f "$TARGET_DIR/.claudeignore" ] && cp "$SOURCE_DIR/.claudeignore" "$TARGET_DIR/.claudeignore"
[ ! -f "$TARGET_DIR/.agentignore" ] && cp "$SOURCE_DIR/.agentignore" "$TARGET_DIR/.agentignore"
[ ! -f "$TARGET_DIR/.github/copilot-instructions.md" ] && cp "$SOURCE_DIR/.github/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
[ ! -f "$TARGET_DIR/.github/PULL_REQUEST_TEMPLATE.md" ] && cp "$SOURCE_DIR/.github/PULL_REQUEST_TEMPLATE.md" "$TARGET_DIR/.github/PULL_REQUEST_TEMPLATE.md"

echo -e "\n========================================================"
echo "   UNIVERSAL INSTALLATION COMPLETED SUCCESSFULLY!      "
echo "========================================================"
echo "Universal compatibility active:"
echo "  - Antigravity IDE, Claude CLI, Codex, OpenCode, Cursor, Windsurf, Copilot"
echo "  - Slash commands: /plan, /tdd, /review, /verify, /build-fix"
echo "  - Token & Secret shields: .agentignore, .claudeignore, .cursorignore"
echo "  - Polyglot skills: Python, Go, Rust, React/Next.js, SQL Migrations, Docker CI/CD"
echo -e "\nHappy hacking!"
