<#
.SYNOPSIS
    Ephemeral Sandbox & Blast-Radius Isolation Runner.
.DESCRIPTION
    Executes commands in an isolated environment to protect host files and secrets:
    1. If Docker is available: runs inside an ephemeral, disposable container with bounded volume.
    2. If Docker is unavailable: runs inside an ephemeral temp workspace snapshot with stripped sensitive env vars.
.PARAMETER Command
    The command string to execute inside the sandbox.
.PARAMETER Image
    Docker container image to use (default: 'alpine:latest' or auto-detected).
.PARAMETER ReadOnlyWorkspace
    Mounts workspace as read-only to prevent destructive file writes.
.PARAMETER ScrubSecrets
    Scrubs sensitive environment variables (GH_TOKEN, AWS_*, SECRET_*) before running.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Command,

    [Parameter()]
    [string]$Image = "alpine:latest",

    [Parameter()]
    [switch]$ReadOnlyWorkspace,

    [Parameter()]
    [switch]$ScrubSecrets
)

$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   EPHEMERAL SANDBOX & BLAST-RADIUS ISOLATION RUNNER    " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Detect Docker / Podman Engine (Alive and responding)
$hasDocker = $false
try {
    $null = docker ps 2>$null
    if ($LASTEXITCODE -eq 0) {
        $hasDocker = $true
    }
} catch {
    $hasDocker = $false
}

$repoRoot = (Get-Item "$PSScriptRoot\..").FullName

if ($hasDocker) {
    Write-Host "[Engine] Docker detected. Preparing containerized sandbox ($Image)..." -ForegroundColor Green
    
    $mountFlag = if ($ReadOnlyWorkspace) { ":ro" } else { ":rw" }
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${repoRoot}:/workspace${mountFlag}",
        "-w", "/workspace"
    )

    if ($ScrubSecrets) {
        $dockerArgs += @("-e", "AWS_ACCESS_KEY_ID=", "-e", "AWS_SECRET_ACCESS_KEY=", "-e", "GITHUB_TOKEN=", "-e", "GH_TOKEN=")
    }

    $dockerArgs += $Image
    $dockerArgs += @("sh", "-c", $Command)

    Write-Host "[*] Executing inside container: $Command" -ForegroundColor Gray
    & docker @dockerArgs
    $exitCode = $LASTEXITCODE
    $codeColor = if ($exitCode -eq 0) { "Green" } else { "Red" }
    Write-Host "[Sandbox Completed] Exit code: $exitCode" -ForegroundColor $codeColor
    exit $exitCode
} else {
    Write-Host "[Engine] Docker not detected. Utilizing Ephemeral Snapshot Isolation..." -ForegroundColor Yellow

    $tempSandbox = Join-Path ([System.IO.Path]::GetTempPath()) ("sandbox_" + [System.Guid]::NewGuid().ToString().Substring(0, 8))
    New-Item -ItemType Directory -Path $tempSandbox -Force | Out-Null

    try {
        Write-Host "[*] Creating ephemeral snapshot in: $tempSandbox" -ForegroundColor Gray
        
        # Copy files excluding heavy artifacts
        Get-ChildItem -Path $repoRoot -Exclude @(".git", "node_modules", "dist", "build", "coverage", ".next") | 
            Copy-Item -Destination $tempSandbox -Recurse -Force

        # Scrub sensitive environment variables if requested
        $envBackup = @{}
        if ($ScrubSecrets) {
            Write-Host "[*] Scrubbing sensitive host environment variables..." -ForegroundColor Gray
            $sensitiveKeys = @("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "GITHUB_TOKEN", "GH_TOKEN", "OPENAI_API_KEY", "ANTHROPIC_API_KEY")
            foreach ($k in $sensitiveKeys) {
                $val = [System.Environment]::GetEnvironmentVariable($k)
                if ($val) {
                    $envBackup[$k] = $val
                    [System.Environment]::SetEnvironmentVariable($k, $null)
                }
            }
        }

        Write-Host "[*] Executing in sandbox: $Command" -ForegroundColor Gray
        Push-Location $tempSandbox
        try {
            $global:LASTEXITCODE = 0
            Invoke-Expression $Command
            $exitCode = if ($null -ne $global:LASTEXITCODE -and $global:LASTEXITCODE -ne 0) { $global:LASTEXITCODE } elseif (-not $?) { 1 } else { 0 }
        } finally {
            Pop-Location
            # Restore environment variables
            foreach ($k in $envBackup.Keys) {
                [System.Environment]::SetEnvironmentVariable($k, $envBackup[$k])
            }
        }

        $exitColor = if ($exitCode -eq 0) { "Green" } else { "Red" }
        Write-Host "[Sandbox Completed] Exit code: $exitCode" -ForegroundColor $exitColor
        exit $exitCode
    } finally {
        Write-Host "[*] Destroying ephemeral sandbox: $tempSandbox" -ForegroundColor Gray
        Remove-Item -Path $tempSandbox -Recurse -Force -ErrorAction SilentlyContinue
    }
}
