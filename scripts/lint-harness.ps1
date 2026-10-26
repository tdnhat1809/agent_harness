# ==============================================================================
# Agent Harness & Skills Validator (Linter)
# Ensures: Frontmatter validity, MCP catalog consistency, hooks schema check
# ==============================================================================
param (
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT HARNESS INTEGRITY LINTER (VALIDATOR)       " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0

# 1. Check MCP Catalog JSON
Write-Host "`n[1] Checking MCP Catalog (.agents/mcp_catalog.json)..." -ForegroundColor Yellow
$mcpCatalogPath = "$rootDir\.agents\mcp_catalog.json"
if (Test-Path $mcpCatalogPath) {
    try {
        $mcp = Get-Content $mcpCatalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $serverCount = ($mcp.mcpServers.PSObject.Properties | Measure-Object).Count
        Write-Host "  [OK] Valid JSON format: $serverCount MCP servers registered." -ForegroundColor Green
    } catch {
        Write-Host "  [FAIL] Invalid JSON in $mcpCatalogPath : $_" -ForegroundColor Red
        $errors++
    }
} else {
    Write-Host "  [WARN] Missing .agents/mcp_catalog.json" -ForegroundColor DarkYellow
    $warnings++
}

# 2. Check Hooks JSON
Write-Host "`n[2] Checking Lifecycle Hooks (.agents/hooks.json)..." -ForegroundColor Yellow
$hooksPath = "$rootDir\.agents\hooks.json"
if (Test-Path $hooksPath) {
    try {
        $hooks = Get-Content $hooksPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "  [OK] Valid hooks schema version: $($hooks.version)" -ForegroundColor Green
    } catch {
        Write-Host "  [FAIL] Invalid JSON in $hooksPath : $_" -ForegroundColor Red
        $errors++
    }
}

# 3. Check Skills YAML Frontmatter
Write-Host "`n[3] Checking Skills Frontmatter (.agents/skills/*/SKILL.md)..." -ForegroundColor Yellow
$skillFiles = Get-ChildItem -Path "$rootDir\.agents\skills" -Recurse -Filter "SKILL.md"
$validSkills = 0

foreach ($sf in $skillFiles) {
    $content = Get-Content $sf.FullName -TotalCount 25 -Encoding UTF8
    $hasOpening = $false
    $hasClosing = $false
    $hasName = $false
    $hasDesc = $false

    foreach ($line in $content) {
        if ($line -match '^---\s*$') {
            if (-not $hasOpening) { $hasOpening = $true; continue }
            if ($hasOpening -and -not $hasClosing) { $hasClosing = $true; break }
        }
        if ($hasOpening -and -not $hasClosing) {
            if ($line -match '^name:\s*\S+') { $hasName = $true }
            if ($line -match '^description:\s*\S+') { $hasDesc = $true }
        }
    }

    $relPath = $sf.FullName.Substring($rootDir.Length + 1)
    if ($hasOpening -and $hasClosing -and $hasName -and $hasDesc) {
        $validSkills++
    } else {
        Write-Host "  [WARN] Incomplete frontmatter in: $relPath" -ForegroundColor DarkYellow
        $warnings++
    }
}
Write-Host "  [OK] $validSkills / $($skillFiles.Count) skills passed frontmatter validation." -ForegroundColor Green

# 4. Check Subagent Roles
Write-Host "`n[4] Checking Subagent Roles (.agents/roles/*.md)..." -ForegroundColor Yellow
$roleFiles = Get-ChildItem -Path "$rootDir\.agents\roles" -Filter "*.md"
Write-Host "  [OK] Found $($roleFiles.Count) subagent roles ready for dispatch." -ForegroundColor Green

# Summary
Write-Host "`n========================================================" -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host "   INTEGRITY AUDIT PASSED! (Errors: 0, Warnings: $warnings)   " -ForegroundColor Green
} else {
    Write-Host "   INTEGRITY AUDIT FAILED! (Errors: $errors, Warnings: $warnings)   " -ForegroundColor Red
    if ($Strict) { exit 1 }
}
Write-Host "========================================================`n" -ForegroundColor Cyan
