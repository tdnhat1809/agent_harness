# ==============================================================================
# Agent Harness Mechanical Commit-Msg Gate for Windows (PowerShell)
# Enforces: Mandate 5 & Invariant 6 (Auto-Experience Journaling for Bug Fixes)
# ==============================================================================
param (
    [Parameter(Mandatory=$true)]
    [string]$CommitMsgFile
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $CommitMsgFile)) {
    exit 0
}

$lines = Get-Content $CommitMsgFile | Where-Object { $_ -notmatch '^\s*#' -and -not [string]::IsNullOrWhiteSpace($_) }
if ($lines.Count -eq 0) {
    exit 0
}

$firstLine = $lines[0].Trim()
$fixPattern = '^(fix|hotfix|bug|patch|resolve)(\([a-zA-Z0-9_.-]+\))?!?:'

if ($firstLine -match $fixPattern) {
    $stagedFiles = git diff --cached --name-only
    $journalUpdated = $false
    foreach ($f in $stagedFiles) {
        if ($f -match '^docs/memory/failure-journal\.md$') {
            $journalUpdated = $true
            break
        }
    }

    if (-not $journalUpdated) {
        Write-Host ""
        Write-Host "❌ [FAILURE JOURNAL GATE REJECTED]" -ForegroundColor Red
        Write-Host "   Defect fix commit detected: `"$firstLine`"" -ForegroundColor Yellow
        Write-Host "   However, 'docs/memory/failure-journal.md' was NOT updated in staged changes!" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Invariant 6 & Guardrails Mandate 5 strictly require documenting the" -ForegroundColor White
        Write-Host "   symptom, root cause, and invariant prevention rule for all bug fixes." -ForegroundColor White
        Write-Host ""
        Write-Host "   Please record the lesson learned using:" -ForegroundColor Cyan
        Write-Host "     PowerShell: .\scripts\record-lesson.ps1 -Symptom `"<error>`" -RootCause `"<cause>`" -Prevention `"<rule>`"" -ForegroundColor Green
        Write-Host "     Bash:       ./scripts/record-lesson.sh `"<symptom>`" `"<cause>`" `"<prevention>`"" -ForegroundColor Green
        Write-Host ""
        Write-Host "   Then stage the journal file and retry:" -ForegroundColor Cyan
        Write-Host "     git add docs/memory/failure-journal.md" -ForegroundColor Green
        Write-Host "     git commit -m `"$firstLine`"" -ForegroundColor Green
        Write-Host ""
        exit 1
    } else {
        Write-Host "✅ [Harness Guard] Defect fix commit paired with failure-journal update." -ForegroundColor Green
    }
}

exit 0
