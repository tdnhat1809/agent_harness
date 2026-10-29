# ==============================================================================
# Agent Harness Plan Archival & Lifecycle Closer (PowerShell)
# Enforces: Clean Transition from Active to Completed Plans
# ==============================================================================
param (
    [string]$PlanName = ""
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$activeDir = Join-Path $rootDir "docs\plans\active"
$completedDir = Join-Path $rootDir "docs\plans\completed"

New-Item -ItemType Directory -Path $completedDir -Force | Out-Null

$activePlans = @(Get-ChildItem -Path $activeDir -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" })

if ($activePlans.Count -eq 0) {
    Write-Host "No active plans available to archive." -ForegroundColor Yellow
    exit 0
}

# Auto-select if only 1 active plan
$targetFile = $null
if ([string]::IsNullOrWhiteSpace($PlanName)) {
    if ($activePlans.Count -eq 1) {
        $targetFile = $activePlans[0]
    } else {
        Write-Host "Multiple active plans found. Please specify via -PlanName:" -ForegroundColor Yellow
        foreach ($p in $activePlans) {
            Write-Host "  - $($p.Name)"
        }
        exit 1
    }
} else {
    foreach ($p in $activePlans) {
        if ($p.Name.Contains($PlanName)) {
            $targetFile = $p
            break
        }
    }
    if (-not $targetFile) {
        Write-Error "Could not find active plan matching: $PlanName"
        exit 1
    }
}

$destPath = Join-Path $completedDir $targetFile.Name
$dateStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Read lines and update status
$lines = Get-Content $targetFile.FullName -Encoding UTF8
$updatedLines = @()
$pendingCount = 0

foreach ($line in $lines) {
    if ($line.Trim().StartsWith("Active | Blocked | Completed") -or $line.Trim().StartsWith("Active")) {
        $updatedLines += "Completed ($dateStr)"
    } else {
        $updatedLines += $line
        if ($line.Trim() -match '^-\s*\[\s*\]') {
            $pendingCount++
        }
    }
}

if ($pendingCount -gt 0) {
    Write-Warning "Plan contains $pendingCount unfinished tasks marked as [ ]."
}

Set-Content -Path $destPath -Value $updatedLines -Encoding UTF8
Remove-Item -Path $targetFile.FullName -Force

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   PLAN SUCCESSFULLY COMPLETED AND ARCHIVED             " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Archived: docs/plans/completed/$($targetFile.Name)" -ForegroundColor Green
Write-Host "  Timestamp: $dateStr" -ForegroundColor DarkGray
Write-Host "========================================================" -ForegroundColor Cyan
