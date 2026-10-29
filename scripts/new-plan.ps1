# ==============================================================================
# Agent Harness Plan Scaffolding Generator (PowerShell)
# Enforces: Durable Planning Protocol & Zero-Drop Multi-Goal Structure
# ==============================================================================
param (
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [string]$Slug = ""
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$templatePath = "$rootDir\docs\templates\exec-plan.md"
$activeDir = "$rootDir\docs\plans\active"

if (-not (Test-Path $templatePath)) {
    Write-Error "Plan template not found at: $templatePath"
    exit 1
}

New-Item -ItemType Directory -Path $activeDir -Force | Out-Null

# Generate slug if empty
if ([string]::IsNullOrWhiteSpace($Slug)) {
    $clean = $Title.ToLower() -replace '[^a-z0-9\s-]', '' -replace '\s+', '-'
    $datePrefix = Get-Date -Format "yyyyMMdd"
    $Slug = "$datePrefix-$clean"
}

$planFile = "$activeDir\$Slug.md"
if (Test-Path $planFile) {
    Write-Warning "Plan file already exists: $planFile"
    exit 0
}

$dateStr = Get-Date -Format "yyyy-MM-dd"
$template = Get-Content $templatePath -Raw -Encoding UTF8

$planContent = $template -replace '# Execution Plan: Title', "# Execution Plan: $Title"
$planContent = $planContent -replace 'Date: YYYY-MM-DD', "Date: $dateStr"
$planContent = $planContent -replace 'Active \| Blocked \| Completed', "Active"

# Pre-seed Multi-Goal Matrix into Progress section
$matrixSection = @"
## Multi-Goal Decomposition Matrix (Zero-Drop)

- [ ] Target 1: Core Implementation & Positive Test (GREEN)
- [ ] Target 2: Negative & Boundary Edge-Case Proof (Edge tests pass)
- [ ] Target 3: Full-Suite Project Regression (`scripts/verify.ps1`) (Exit Code 0)
- [ ] Target 4: Failure Journal & Lesson Learned Checkpoint (`ERR-XXX`)
"@

$planContent = $planContent -replace '## Progress\s*\n\s*- \[ \] Step\.', "$matrixSection`n`n## Progress`n- [ ] Task 1: Scaffolding and setup"

Set-Content -Path $planFile -Value $planContent -Encoding UTF8

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   NEW DURABLE EXECUTION PLAN CREATED                  " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Plan Title:    $Title" -ForegroundColor Yellow
Write-Host "  Location:      docs/plans/active/$Slug.md" -ForegroundColor Green
Write-Host "  Command to Run: .\scripts\plan-status.ps1" -ForegroundColor DarkGray
Write-Host "========================================================`n" -ForegroundColor Cyan
