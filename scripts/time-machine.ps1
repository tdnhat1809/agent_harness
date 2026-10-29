<#
.SYNOPSIS
    Micro-Checkpoint Time Machine & State Rollback Engine.
.DESCRIPTION
    Creates granular shadow checkpoints before file mutations, allowing exact step-by-step
    rollbacks while strictly preserving docs/memory/ and docs/plans/ from destruction.
.PARAMETER Action
    Operation to perform: 'snapshot' (default), 'list', 'rollback', 'purge'.
.PARAMETER Message
    Description tag for snapshot (e.g. "before modifying auth middleware").
.PARAMETER Step
    Snapshot ID or index to rollback to (e.g. 1 or snap_20261029_153000).
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("snapshot", "list", "rollback", "purge")]
    [string]$Action = "snapshot",

    [Parameter(Position = 1)]
    [string]$Message = "Manual checkpoint before task mutation",

    [Parameter()]
    [string]$Step = ""
)

$ErrorActionPreference = "Stop"

$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$snapshotBaseDir = Join-Path $rootDir ".harness_snapshots"
if (-not (Test-Path $snapshotBaseDir)) {
    New-Item -ItemType Directory -Path $snapshotBaseDir -Force | Out-Null
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   MICRO-CHECKPOINT TIME MACHINE (STATE ROLLBACK)       " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

switch ($Action) {
    "snapshot" {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $snapId = "snap_$timestamp"
        $targetDir = Join-Path $snapshotBaseDir $snapId
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

        Write-Host "[*] Creating shadow snapshot: $snapId" -ForegroundColor Yellow
        Write-Host "    Tag: $Message" -ForegroundColor Gray

        # Metadata
        $meta = [PSCustomObject]@{
            Id = $snapId
            Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            Message = $Message
            Branch = (git branch --show-current 2>&1)
            HeadCommit = (git rev-parse --short HEAD 2>&1)
        }
        $meta | ConvertTo-Json | Set-Content -Path (Join-Path $targetDir "meta.json") -Encoding UTF8

        # Copy tracking files (exclude .git, node_modules, .harness_snapshots, docs/memory, docs/plans)
        $filesToBackup = Get-ChildItem -Path $rootDir -Recurse -File | Where-Object {
            $_.FullName -notmatch '[\\/](\.git|node_modules|dist|build|\.next|\.harness_snapshots|docs[\\/]memory|docs[\\/]plans)[\\/]'
        }

        $backedCount = 0
        foreach ($f in $filesToBackup) {
            $relPath = $f.FullName.Substring($rootDir.Length).TrimStart("\/")
            $destFile = Join-Path $targetDir $relPath
            $destParent = Split-Path $destFile -Parent
            if (-not (Test-Path $destParent)) { New-Item -ItemType Directory -Path $destParent -Force | Out-Null }
            Copy-Item -Path $f.FullName -Destination $destFile -Force
            $backedCount++
        }

        Write-Host "[OK] Snapshot captured ($backedCount files backed up)." -ForegroundColor Green
        Write-Host "     Snapshot ID: $snapId" -ForegroundColor White
        Write-Host "     Rollback command: .\scripts\time-machine.ps1 -Action rollback -Step $snapId" -ForegroundColor Cyan
    }

    "list" {
        Write-Host "[*] Available Checkpoints in Time Machine:" -ForegroundColor Yellow
        $snaps = Get-ChildItem -Path $snapshotBaseDir -Directory | Sort-Object Name -Descending
        if ($snaps.Count -eq 0) {
            Write-Host "  No checkpoints found. Create one with: .\scripts\time-machine.ps1 snapshot" -ForegroundColor DarkGray
            exit 0
        }

        $i = 1
        foreach ($s in $snaps) {
            $metaFile = Join-Path $s.FullName "meta.json"
            $msg = "No description"
            $ts = $s.Name
            if (Test-Path $metaFile) {
                $meta = Get-Content $metaFile -Raw | ConvertFrom-Json
                $msg = $meta.Message
                $ts = $meta.Timestamp
            }
            Write-Host "  [$i] $($s.Name) ($ts)" -ForegroundColor Green
            Write-Host "      Tag:    $msg" -ForegroundColor Gray
            Write-Host "      Path:   $($s.FullName)" -ForegroundColor DarkGray
            $i++
        }
    }

    "rollback" {
        if ($Step -eq "") {
            # Default to most recent snapshot
            $snaps = Get-ChildItem -Path $snapshotBaseDir -Directory | Sort-Object Name -Descending
            if ($snaps.Count -eq 0) {
                Write-Host "[FAIL] No snapshots available for rollback." -ForegroundColor Red
                exit 1
            }
            $targetSnap = $snaps[0]
        } elseif (Test-Path (Join-Path $snapshotBaseDir $Step)) {
            $targetSnap = Get-Item (Join-Path $snapshotBaseDir $Step)
        } else {
            # Try index 1, 2, 3
            $snaps = Get-ChildItem -Path $snapshotBaseDir -Directory | Sort-Object Name -Descending
            $idx = 0
            if ([int]::TryParse($Step, [ref]$idx) -and $idx -ge 1 -and $idx -le $snaps.Count) {
                $targetSnap = $snaps[$idx - 1]
            } else {
                Write-Host "[FAIL] Snapshot '$Step' not found." -ForegroundColor Red
                exit 1
            }
        }

        Write-Host "[*] Rolling back workspace to checkpoint: $($targetSnap.Name)..." -ForegroundColor Yellow

        $backedFiles = Get-ChildItem -Path $targetSnap.FullName -Recurse -File | Where-Object { $_.Name -ne "meta.json" }
        $restored = 0
        foreach ($f in $backedFiles) {
            $relPath = $f.FullName.Substring($targetSnap.FullName.Length).TrimStart("\/")
            $destFile = Join-Path $rootDir $relPath
            $destParent = Split-Path $destFile -Parent
            if (-not (Test-Path $destParent)) { New-Item -ItemType Directory -Path $destParent -Force | Out-Null }
            Copy-Item -Path $f.FullName -Destination $destFile -Force
            $restored++
        }

        Write-Host "[OK] Rollback complete! Restored $restored files to checkpoint state." -ForegroundColor Green
        Write-Host "     Preserved: docs/memory/ and docs/plans/ were kept intact." -ForegroundColor Cyan
    }

    "purge" {
        Write-Host "[*] Purging snapshots older than 24 hours..." -ForegroundColor Yellow
        $cutoff = (Get-Date).AddHours(-24)
        $oldSnaps = Get-ChildItem -Path $snapshotBaseDir -Directory | Where-Object { $_.CreationTime -lt $cutoff }
        foreach ($s in $oldSnaps) {
            Remove-Item -Path $s.FullName -Recurse -Force
            Write-Host "  Purged: $($s.Name)" -ForegroundColor DarkGray
        }
        Write-Host "[OK] Purge complete." -ForegroundColor Green
    }
}
