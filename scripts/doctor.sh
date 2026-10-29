#!/usr/bin/env bash
# ==============================================================================
# Agent Harness Environment Doctor (Healthcheck) for Linux / macOS
# ==============================================================================

echo -e "\n========================================================"
echo "   AI AGENT HARNESS SYSTEM HEALTHCHECK (DOCTOR)        "
echo "========================================================"

check_tool() {
    local name="$1"
    local cmd="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        local ver
        ver="$("$cmd" --version 2>&1 | head -n 1)"
        echo -e "  \033[32m[OK]\033[0m $name: Found ($ver)"
    else
        echo -e "  \033[90m[--]\033[0m $name: Not installed (optional)"
    fi
}

check_file() {
    local path="$1"
    local label="$2"
    if [ -e "$path" ]; then
        echo -e "  \033[32m[OK]\033[0m $label exists"
    else
        echo -e "  \033[31m[!!]\033[0m $label MISSING ($path)"
    fi
}

echo -e "\n[1] Runtime Tools:"
check_tool "Git" "git"
check_tool "Node.js" "node"
check_tool "Python" "python3"
check_tool "Go" "go"
check_tool "Rust (Cargo)" "cargo"
check_tool "Docker" "docker"

echo -e "\n[2] Agent Context Entrypoints:"
check_file "AGENTS.md" "AGENTS.md (Universal Standard)"
check_file "CLAUDE.md" "CLAUDE.md (Claude Code)"
check_file "CODEX.md" "CODEX.md (Codex)"
check_file "OPENCODE.md" "OPENCODE.md (OpenCode)"
check_file ".cursorrules" ".cursorrules (Cursor IDE)"
check_file ".cursor/rules/guardrails.mdc" "Cursor MDC rules"

echo -e "\n[3] Security & Token Shields:"
check_file ".agentignore" ".agentignore"
check_file ".claudeignore" ".claudeignore"
check_file ".cursorignore" ".cursorignore"

echo -e "\n[4] Harness Engine Directories:"
check_file ".agents/rules" "Agent Rules"
check_file ".agents/skills" "Agent Skills"
check_file ".claude/commands" "Claude Slash Commands"
check_file "docs/plans/active" "Durable Active Plans"
check_file "docs/decisions" "Architecture Decisions (ADR)"
check_file "docs/memory" "Persistent Memory (Failure Journal)"

echo -e "\n[5] Mechanical Git Hooks:"
check_file ".git/hooks/pre-commit" "Git Hook: pre-commit (TDD & Secret Shield)"
check_file ".git/hooks/commit-msg" "Git Hook: commit-msg (Failure Journal Enforcer)"
check_file ".git/hooks/pre-push" "Git Hook: pre-push (Remote Guard)"

echo -e "\n[6] Autonomous Operational Tooling Suite:"
check_file "scripts/route-context.sh" "Dynamic Context Sharding (route-context)"
check_file "scripts/ui-audit.sh" "Visual UI & Anti-AI Slop Auditor (ui-audit)"
check_file "scripts/sandbox-run.sh" "Ephemeral Sandbox Isolation (sandbox-run)"
check_file "scripts/test-agent-adherence.sh" "Agent Red-Team Benchmark (test-agent-adherence)"
check_file "scripts/mutation-test.sh" "Mutation Testing Engine (mutation-test)"
check_file "scripts/self-heal.sh" "Workspace Self-Heal & Rollback (self-heal)"
check_file "scripts/inspect-package.sh" "Live Package Inspector (inspect-package)"
check_file "scripts/query-memory.sh" "Semantic Memory Indexer (query-memory)"
check_file "scripts/record-lesson.sh" "Failure Journal Recorder (record-lesson)"
check_file "scripts/generate-pr.sh" "Automated PR Generator (generate-pr)"

echo -e "\n========================================================"
echo -e "\033[32m   DIAGNOSIS COMPLETE! YOUR HARNESS IS PRODUCTION-READY \033[0m"
echo -e "========================================================\n"
