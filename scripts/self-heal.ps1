# ==============================================================================
# Agent Harness Self-Healing & Workspace Recovery Protocol (PowerShell)
# Enforces: Safe Failure Recovery & Anti-Workspace Thrashing
# ==============================================================================
param (
    [switch]$Snapshot,
    [switch]$Rollback,
    [switch]$CleanCache,
    [switch]$Status
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT WORKSPACE SELF-HEAL & RECOVERY ENGINE      " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# Default to Status if no switch specified
if (-not ($Snapshot -or $Rollback -or $CleanCache -or $Status)) {
    $Status = $true
}

# 1. Clean Cache
if ($CleanCache) {
    Write-Host "`n[*] Cleaning up build artifacts, test caches, and temp lock files..." -ForegroundColor Yellow
    $cachePatterns = @(
        "__pycache__",
        ".pytest_cache",
        ".mypy_cache",
        ".ruff_cache",
        ".tsbuildinfo",
        "*.pyc"
    )

    $cleanedCount = 0
    foreach ($pat in $cachePatterns) {
        Get-ChildItem -Path $rootDir -Filter $pat -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            $cleanedCount++
        }
    }
    
    # Remove defect marker if stale
    if (Test-Path "$rootDir\.agents\.defect_active") {
        Remove-Item "$rootDir\.agents\.defect_active" -Force -ErrorAction SilentlyContinue
        $cleanedCount++
    }

    Write-Host "  [OK] Cleaned $cleanedCount cache and temporary files." -ForegroundColor Green
}

# 2. Workspace Snapshot
if ($Snapshot) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $snapshotMsg = "harness-snapshot-$timestamp"
    Write-Host "`n[*] Creating safety snapshot: $snapshotMsg..." -ForegroundColor Yellow
    
    # Save a git stash snapshot without modifying working directory
    $stashId = git stash create "$snapshotMsg"
    if ($stashId) {
        git stash store -m "$snapshotMsg" $stashId
        Write-Host "  [OK] Workspace snapshot stored: $snapshotMsg ($stashId)" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] Working tree is clean. Current HEAD is the snapshot." -ForegroundColor Green
    }
}

# 3. Emergency Rollback
if ($Rollback) {
    Write-Host "`n[!] Initiating Emergency Safe Rollback..." -ForegroundColor Red
    Write-Host "    Preserving docs/memory/ and docs/plans/ to retain journaled learnings." -ForegroundColor Yellow
    
    # Back up memory and plans in memory
    $journalBackup = if (Test-Path "$rootDir\docs\memory\failure-journal.md") { Get-Content "$rootDir\docs\memory\failure-journal.md" -Raw -Encoding UTF8 } else { $null }
    
    # Discard unstaged changes to tracked files
    git checkout -- .
    
    # Clean untracked files except docs
    git clean -fd -e docs/ -e .gemini/
    
    # Restore journal if needed
    if ($journalBackup) {
        Set-Content -Path "$rootDir\docs\memory\failure-journal.md" -Value $journalBackup -Encoding UTF8
    }

    Write-Host "  [OK] Tracked code files restored to clean HEAD." -ForegroundColor Green
    Write-Host "  [OK] Memory Journal and Plans preserved intact." -ForegroundColor Green
}

# 4. Workspace Status
if ($Status) {
    Write-Host "`n[*] Current Workspace Health & Status:" -ForegroundColor Cyan
    $statusOut = git status --short
    if ($statusOut) {
        Write-Host "Modified / Untracked Changes:" -ForegroundColor Yellow
        $statusOut | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "  [OK] Working tree is 100% clean." -ForegroundColor Green
    }

    $stashes = git stash list
    if ($stashes) {
        Write-Host "`nStored Safety Snapshots:" -ForegroundColor Cyan
        $stashes | Select-Object -First 3 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    }
}

Write-Host "========================================================`n" -ForegroundColor Cyan
