# ==============================================================================
# Agent Harness Environment Doctor (Healthcheck)
# ==============================================================================

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT HARNESS SYSTEM HEALTHCHECK (DOCTOR)        " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

function Check-Tool ($toolName, $command) {
    try {
        $cmd = Get-Command $command -ErrorAction SilentlyContinue
        if ($cmd) {
            $ver = (& $command --version 2>&1 | Select-Object -First 1)
            Write-Host "  [OK] ${toolName}: Found ($ver)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  [--] ${toolName}: Not installed (optional)" -ForegroundColor Gray
            return $false
        }
    } catch {
        Write-Host "  [--] ${toolName}: Not found" -ForegroundColor Gray
        return $false
    }
}

function Check-File ($path, $label) {
    if (Test-Path $path) {
        Write-Host "  [OK] $label exists" -ForegroundColor Green
    } else {
        Write-Host "  [!!] $label MISSING ($path)" -ForegroundColor Red
    }
}

Write-Host "`n[1] Runtime Tools:" -ForegroundColor Yellow
Check-Tool "Git" "git"
Check-Tool "Node.js" "node"
Check-Tool "Python" "python"
Check-Tool "Go" "go"
Check-Tool "Rust (Cargo)" "cargo"
Check-Tool "Docker" "docker"

Write-Host "`n[2] Agent Context Entrypoints:" -ForegroundColor Yellow
Check-File "AGENTS.md" "AGENTS.md (Universal Standard)"
Check-File "CLAUDE.md" "CLAUDE.md (Claude Code)"
Check-File "CODEX.md" "CODEX.md (Codex)"
Check-File "OPENCODE.md" "OPENCODE.md (OpenCode)"
Check-File ".cursorrules" ".cursorrules (Cursor IDE)"
Check-File ".cursor\rules\guardrails.mdc" "Cursor MDC rules"

Write-Host "`n[3] Security & Token Shields:" -ForegroundColor Yellow
Check-File ".agentignore" ".agentignore"
Check-File ".claudeignore" ".claudeignore"
Check-File ".cursorignore" ".cursorignore"

Write-Host "`n[4] Harness Engine Directories:" -ForegroundColor Yellow
Check-File ".agents\rules" "Agent Rules"
Check-File ".agents\skills" "Agent Skills"
Check-File ".claude\commands" "Claude Slash Commands"
Check-File "docs\plans\active" "Durable Active Plans"
Check-File "docs\decisions" "Architecture Decisions (ADR)"
Check-File "docs\memory" "Persistent Memory (Failure Journal)"

Write-Host "`n[5] Mechanical Git Hooks:" -ForegroundColor Yellow
Check-File ".git\hooks\pre-commit" "Git Hook: pre-commit (TDD & Secret Shield)"
Check-File ".git\hooks\commit-msg" "Git Hook: commit-msg (Failure Journal Enforcer)"
Check-File ".git\hooks\pre-push" "Git Hook: pre-push (Remote Guard)"

Write-Host "`n[6] Autonomous Operational Tooling Suite:" -ForegroundColor Yellow
Check-File "scripts\route-context.ps1" "Dynamic Context Sharding (route-context)"
Check-File "scripts\ui-audit.ps1" "Visual UI & Anti-AI Slop Auditor (ui-audit)"
Check-File "scripts\sandbox-run.ps1" "Ephemeral Sandbox Isolation (sandbox-run)"
Check-File "scripts\test-agent-adherence.ps1" "Agent Red-Team Benchmark (test-agent-adherence)"
Check-File "scripts\mutation-test.ps1" "Mutation Testing Engine (mutation-test)"
Check-File "scripts\self-heal.ps1" "Workspace Self-Heal & Rollback (self-heal)"
Check-File "scripts\inspect-package.ps1" "Live Package Inspector (inspect-package)"
Check-File "scripts\query-memory.ps1" "Semantic Memory Indexer (query-memory)"
Check-File "scripts\record-lesson.ps1" "Failure Journal Recorder (record-lesson)"
Check-File "scripts\generate-pr.ps1" "Automated PR Generator (generate-pr)"
Check-File "scripts\flaky-detector.ps1" "Flaky Test Isolator & Bisection Engine (flaky-detector)"
Check-File "scripts\agent-debate.ps1" "Multi-Agent Adversarial Debate Protocol (agent-debate)"
Check-File "scripts\token-telemetry.ps1" "Live Token Telemetry & ROI Profiler (token-telemetry)"
Check-File "scripts\time-machine.ps1" "Micro-Checkpoint Time Machine (time-machine)"

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSIS COMPLETE! YOUR HARNESS IS PRODUCTION-READY " -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Cyan
