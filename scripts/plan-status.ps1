# ==============================================================================
# Agent Harness Plan Status & Kanban Progress Tracker (PowerShell)
# Enforces: Observability of Active Durable Plans
# ==============================================================================
$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$activeDir = Join-Path $rootDir "docs\plans\active"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT ACTIVE PLANS & KANBAN STATUS TRACKER       " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

if (-not (Test-Path $activeDir)) {
    Write-Host "No active plans directory found at: docs/plans/active" -ForegroundColor Yellow
    exit 0
}

$planFiles = @(Get-ChildItem -Path $activeDir -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" })

if ($planFiles.Count -eq 0) {
    Write-Host "No active durable plans in docs/plans/active/" -ForegroundColor Green
    Write-Host "To create a new plan: .\scripts\new-plan.ps1 -Title '<Goal>'" -ForegroundColor DarkGray
    Write-Host "========================================================" -ForegroundColor Cyan
    exit 0
}

foreach ($pf in $planFiles) {
    $lines = Get-Content $pf.FullName -Encoding UTF8
    
    $title = "Untitled Plan"
    $status = "Active"
    $completedCount = 0
    $pendingCount = 0
    $pendingTasks = @()

    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed.StartsWith("# Execution Plan:")) {
            $title = $trimmed.Substring(17).Trim()
        } elseif ($trimmed -match '^-\s*\[x\]\s*(.+)') {
            $completedCount++
        } elseif ($trimmed -match '^-\s*\[\s*\]\s*(.+)') {
            $pendingCount++
            if ($pendingTasks.Count -lt 3) {
                $pendingTasks += $matches[1].Trim()
            }
        }
    }

    $totalTasks = $completedCount + $pendingCount
    $pct = if ($totalTasks -gt 0) { [math]::Round(($completedCount / $totalTasks) * 100) } else { 0 }

    # Draw ASCII progress bar (12 blocks)
    $blocks = [math]::Round(($pct / 100) * 12)
    $bar = ("#" * $blocks) + ("-" * (12 - $blocks))

    Write-Host "Plan: $title ($($pf.Name))" -ForegroundColor Yellow
    Write-Host "  Status:   $status" -ForegroundColor Cyan
    Write-Host "  Progress: [$bar] $pct% ($completedCount / $totalTasks tasks done)" -ForegroundColor $(if ($pct -eq 100) { "Green" } elseif ($pct -ge 50) { "Yellow" } else { "White" })

    if ($pendingTasks.Count -gt 0) {
        Write-Host "  Next Pending Tasks:" -ForegroundColor DarkGray
        foreach ($t in $pendingTasks) {
            Write-Host "    - $t" -ForegroundColor DarkYellow
        }
    }
    Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray
}

Write-Host "========================================================" -ForegroundColor Cyan
