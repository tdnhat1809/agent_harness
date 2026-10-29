# ==============================================================================
# Agent Harness Autonomous Package & GitHub Inspector (PowerShell)
# Enforces: Invariant 1 (Ground Truth) & Epistemic Honesty Protocol
# Automatically fetches live package metadata, versions, and repository details.
# ==============================================================================
param (
    [string]$Npm = "",
    [string]$Pypi = "",
    [string]$GitHub = "",
    [string]$Search = ""
)

$ErrorActionPreference = "Continue"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT PACKAGE & REPO RESEARCH INSPECTOR          " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. NPM Registry Inspection
if ($Npm) {
    Write-Host "[*] Querying NPM Registry for: $Npm..." -ForegroundColor Yellow
    try {
        $url = "https://registry.npmjs.org/$Npm/latest"
        $resp = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10 -ErrorAction Stop
        
        Write-Host "  Package:      $($resp.name)" -ForegroundColor Green
        Write-Host "  Latest Ver:   $($resp.version)" -ForegroundColor Green
        Write-Host "  Description:  $($resp.description)" -ForegroundColor White
        Write-Host "  License:      $($resp.license)" -ForegroundColor DarkGray
        if ($resp.homepage) { Write-Host "  Homepage:     $($resp.homepage)" -ForegroundColor Cyan }
        if ($resp.repository -and $resp.repository.url) { Write-Host "  Repository:   $($resp.repository.url)" -ForegroundColor Cyan }
        
        if ($resp.dependencies) {
            $depCount = ($resp.dependencies.PSObject.Properties | Measure-Object).Count
            Write-Host "  Dependencies: $depCount packages" -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "❌ Failed to query NPM registry: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 2. PyPI Registry Inspection
if ($Pypi) {
    Write-Host "[*] Querying PyPI Registry for: $Pypi..." -ForegroundColor Yellow
    try {
        $url = "https://pypi.org/pypi/$Pypi/json"
        $resp = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10 -ErrorAction Stop
        $info = $resp.info

        Write-Host "  Package:      $($info.name)" -ForegroundColor Green
        Write-Host "  Latest Ver:   $($info.version)" -ForegroundColor Green
        Write-Host "  Summary:      $($info.summary)" -ForegroundColor White
        Write-Host "  Author:       $($info.author)" -ForegroundColor DarkGray
        Write-Host "  License:      $($info.license)" -ForegroundColor DarkGray
        if ($info.home_page) { Write-Host "  Homepage:     $($info.home_page)" -ForegroundColor Cyan }
        if ($info.project_url) { Write-Host "  Project URL:  $($info.project_url)" -ForegroundColor Cyan }
    } catch {
        Write-Host "❌ Failed to query PyPI: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3. GitHub Repository Inspection
if ($GitHub) {
    Write-Host "[*] Querying GitHub Repository for: $GitHub..." -ForegroundColor Yellow
    
    $ghAvailable = Get-Command gh -ErrorAction SilentlyContinue
    $success = $false
    if ($ghAvailable) {
        $ghOut = & gh repo view $GitHub 2>&1
        if ($LASTEXITCODE -eq 0 -and $ghOut -notmatch '401: Requires authentication') {
            Write-Host "  [Using gh CLI]" -ForegroundColor DarkGray
            $ghOut | Select-Object -First 15 | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            $success = $true
        }
    }
    
    if (-not $success) {
        Write-Host "  [Using Public GitHub REST API]" -ForegroundColor DarkGray
        try {
            $apiUrl = "https://api.github.com/repos/$GitHub"
            $apiResp = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{ "User-Agent" = "AgentHarness" } -TimeoutSec 10
            Write-Host "  Repo:        $($apiResp.full_name)" -ForegroundColor Green
            Write-Host "  Stars:       $($apiResp.stargazers_count)" -ForegroundColor Yellow
            Write-Host "  Description: $($apiResp.description)" -ForegroundColor White
            Write-Host "  Default Br:  $($apiResp.default_branch)" -ForegroundColor DarkGray
            Write-Host "  Clone URL:   $($apiResp.clone_url)" -ForegroundColor Cyan
        } catch {
            Write-Host "❌ Failed to query GitHub API: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# 4. Search GitHub Repositories
if ($Search) {
    Write-Host "[*] Searching GitHub for repos matching: $Search..." -ForegroundColor Yellow
    $ghAvailable = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghAvailable) {
        gh search repos $Search --limit 5 --sort stars
    } else {
        Write-Host "GitHub CLI (gh) not found in PATH for search command." -ForegroundColor Yellow
    }
}

Write-Host "========================================================`n" -ForegroundColor Cyan
