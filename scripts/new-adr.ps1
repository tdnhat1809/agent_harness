# ==============================================================================
# Architecture Decision Record (ADR) Generator (PowerShell)
# Automatically creates the next numbered ADR from docs/templates/decision.md
# ==============================================================================
param (
    [Parameter(Mandatory=$true)]
    [string]$Title
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$decisionsDir = "$rootDir\docs\decisions"

if (-not (Test-Path $decisionsDir)) {
    New-Item -ItemType Directory -Path $decisionsDir -Force | Out-Null
}

# 1. Determine next sequence number
$existing = Get-ChildItem -Path $decisionsDir -Filter "*.md"
$maxNum = 0

foreach ($f in $existing) {
    if ($f.Name -match '^(\d{4})-') {
        $val = [int]$matches[1]
        if ($val -gt $maxNum) { $maxNum = $val }
    }
}

$nextNum = "{0:D4}" -f ($maxNum + 1)

# 2. Format filename slug
$slug = $Title.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
$fileName = "$nextNum-$slug.md"
$filePath = "$decisionsDir\$fileName"

# 3. Format ADR content
$today = Get-Date -Format "yyyy-MM-dd"
$adrContent = @"
# $nextNum $Title

Date: $today

## Status

Proposed

## Context

What problem, constraint, or ambiguity forced this decision?

## Decision

What did we decide?

## Alternatives Considered

1. Alternative A
2. Alternative B

## Consequences

Positive:

- Benefit 1

Tradeoffs:

- Tradeoff 1

## Follow-Up

- Action item 1
"@

Set-Content -Path $filePath -Value $adrContent -Encoding UTF8
Write-Host "✅ [ADR Generator] Created new Architecture Decision Record:" -ForegroundColor Green
Write-Host "   $filePath" -ForegroundColor Cyan
