# ==============================================================================
# Agent Context Compaction & Checkpoint Generator (PowerShell)
# Summarizes live progress into docs/scratchpad.md for zero-loss session reset
# ==============================================================================
param (
    [string]$Completed = "",
    [string]$NextSteps = "",
    [string]$Blockers = "None"
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$scratchpadPath = "$rootDir\docs\scratchpad.md"

$nowStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$branch = git rev-parse --abbrev-ref HEAD 2>$null
if (-not $branch) { $branch = "main" }

# 1. Prepare Content Blocks
$gitStatus = git status --short 2>$null
if (-not $gitStatus) { $gitStatus = "Working tree clean - All changes committed." }

$activePlans = Get-ChildItem -Path "$rootDir\docs\plans\active" -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" }
if ($activePlans) {
    $planList = @()
    foreach ($p in $activePlans) {
        $planList += "- [$($p.Name)](file:///$($p.FullName -replace '\\', '/'))"
    }
    $plansText = $planList -join "`n"
} else {
    $plansText = "- None (No ongoing durable plans)."
}

if (-not $Completed) {
    $Completed = "- Synchronized progress and updated affected files."
}
if (-not $NextSteps) {
    $NextSteps = "- Continue executing tasks in the active plan."
}

$checkpointContent = @"
# Live Session Scratchpad & Checkpoint

> **Last Updated**: $nowStr  
> **Git Branch**: `$branch`  
> **Next Session Prompt**: *"Read docs/scratchpad.md and resume next steps."*

---

## 1. Completed Tasks (Nhiem vu da hoan thanh)
$Completed

---

## 2. Next Steps (Cac buoc ke tiep)
$NextSteps

---

## 3. Blockers & Invariants (Tro ngai & Rui ro)
- $Blockers

---

## 4. Empirical Runtime State (Trang thai thuc thi)

### Staged & Modified Files (Git Status):
```text
$gitStatus
```

### Active Plans in docs/plans/active/:
$plansText
"@

Set-Content -Path $scratchpadPath -Value $checkpointContent -Encoding UTF8

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   SESSION CHECKPOINT RECORDED SUCCESSFULLY!           " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "File updated: docs/scratchpad.md" -ForegroundColor Yellow
Write-Host "`nYou can safely clear context / start a new session." -ForegroundColor Cyan
Write-Host "In the new session, prompt:" -ForegroundColor White
Write-Host "  -> 'Read docs/scratchpad.md and resume'`n" -ForegroundColor Green
