# ==============================================================================
# Agent Harness Token-Efficient Memory & Knowledge Query Engine (PowerShell)
# Enforces: Fast, Low-Token Context Retrieval from Persistent Memory
# ==============================================================================
param (
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [int]$Top = 5
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT MEMORY & KNOWLEDGE RETRIEVAL (QUERY)       " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "[*] Searching for: $Query" -ForegroundColor Yellow

$results = @()
$terms = $Query.ToLower().Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)

# 1. Search in docs/memory/failure-journal.md
$journalPath = Join-Path $rootDir "docs\memory\failure-journal.md"
if (Test-Path $journalPath) {
    $lines = Get-Content $journalPath -Encoding UTF8
    foreach ($line in $lines) {
        if ($line.StartsWith("|") -and $line.Contains("ERR-")) {
            $parts = $line.Split("|")
            if ($parts.Count -ge 6) {
                $id = $parts[1].Trim()
                $date = $parts[2].Trim()
                $symptom = $parts[3].Trim()
                $rootCause = $parts[4].Trim()
                $prevention = $parts[5].Trim()

                $fullText = ($id + " " + $date + " " + $symptom + " " + $rootCause + " " + $prevention).ToLower()
                $matchCount = 0
                foreach ($t in $terms) {
                    if ($fullText.Contains($t)) { $matchCount++ }
                }

                if ($matchCount -gt 0) {
                    $results += [PSCustomObject]@{
                        Source = "Failure Journal"
                        ID = $id
                        Score = $matchCount
                        Summary = $symptom
                        Details = "Cause: $rootCause | Rule: $prevention"
                    }
                }
            }
        }
    }
}

# 2. Search in docs/decisions/*.md
$decisionsDir = Join-Path $rootDir "docs\decisions"
if (Test-Path $decisionsDir) {
    $files = Get-ChildItem -Path $decisionsDir -Filter "*.md" -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw -Encoding UTF8
        $matchCount = 0
        foreach ($t in $terms) {
            if ($content.ToLower().Contains($t)) { $matchCount++ }
        }
        if ($matchCount -gt 0) {
            $results += [PSCustomObject]@{
                Source = "ADR Decision"
                ID = $f.BaseName
                Score = $matchCount
                Summary = "Architecture Decision Record"
                Details = "Path: docs/decisions/$($f.Name)"
            }
        }
    }
}

if ($results.Count -eq 0) {
    Write-Host "No matching memory entries found for: $Query" -ForegroundColor DarkGray
    Write-Host "========================================================" -ForegroundColor Cyan
    exit 0
}

# Sort by relevance score
$sorted = $results | Sort-Object -Property Score -Descending | Select-Object -First $Top

Write-Host "Found $($sorted.Count) relevant memory items:" -ForegroundColor Green
foreach ($item in $sorted) {
    Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[$($item.Source)] $($item.ID)" -ForegroundColor Cyan
    Write-Host "  Symptom: $($item.Summary)" -ForegroundColor White
    Write-Host "  $($item.Details)" -ForegroundColor DarkYellow
}
Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Token-efficient extraction complete." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
