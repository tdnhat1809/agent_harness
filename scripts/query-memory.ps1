# ==============================================================================
# Agent Harness Semantic Memory & Precedent Indexer (BM25 / N-Gram Enhanced)
# Enforces: High-Signal, Semantic Context Retrieval from Persistent Memory
# ==============================================================================
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Query,

    [Parameter(Position=1)]
    [int]$Top = 5,

    [Parameter()]
    [switch]$Semantic
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   SEMANTIC MEMORY & PRECEDENT RETRIEVAL (BM25/N-GRAM) " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "[*] Query: $Query" -ForegroundColor Yellow

# Synonym dictionary for semantic expansion (zero-dependency)
$synonyms = @{
    "deadlock"    = @("race", "concurrency", "lock", "thread", "hang", "timeout", "timing")
    "race"        = @("deadlock", "concurrency", "timing", "async", "atomic")
    "api"         = @("endpoint", "route", "http", "contract", "fastapi", "rest")
    "database"    = @("migration", "sql", "schema", "postgres", "prisma", "sqlite", "table")
    "migration"   = @("database", "schema", "rollback", "expand", "contract")
    "secret"      = @("key", "token", "credential", "env", "leak", "shield")
    "test"        = @("tdd", "hollow", "verify", "mock", "regression", "mutation", "red", "green")
    "ui"          = @("layout", "css", "frontend", "emoji", "slop", "component", "visual", "contrast")
    "emoji"       = @("slop", "icon", "visual", "lucide", "heroicons")
    "memory"      = @("journal", "precedent", "adr", "lesson", "knowledge")
    "hook"        = @("pre-commit", "commit-msg", "pre-push", "gate", "guardrail")
}

# Tokenize query
$rawTokens = $Query.ToLower().Split(" `t`r`n,.-/\|:;()[]{}'`"", [System.StringSplitOptions]::RemoveEmptyEntries)
$stopWords = @("the", "a", "an", "is", "in", "at", "of", "on", "for", "to", "and", "or", "with", "của", "và", "cho", "ở", "với", "là", "trong", "được")
$queryTokens = @($rawTokens | Where-Object { $stopWords -notcontains $_ })

# Semantic expanded tokens
$expandedTokens = [System.Collections.Generic.List[string]]::new()
foreach ($t in $queryTokens) {
    if (-not $expandedTokens.Contains($t)) { $expandedTokens.Add($t) }
    if ($synonyms.ContainsKey($t)) {
        foreach ($syn in $synonyms[$t]) {
            if (-not $expandedTokens.Contains($syn)) { $expandedTokens.Add($syn) }
        }
    }
}

$documents = @()

# 1. Harvest docs/memory/failure-journal.md
$journalPath = Join-Path $rootDir "docs\memory\failure-journal.md"
if (Test-Path $journalPath) {
    $lines = Get-Content $journalPath -Encoding UTF8
    foreach ($line in $lines) {
        if ($line.StartsWith("|") -and $line.Contains("ERR-")) {
            $parts = $line.Split("|")
            if ($parts.Count -ge 6) {
                $documents += [PSCustomObject]@{
                    Source = "Failure Journal"
                    ID = $parts[1].Trim()
                    Summary = $parts[3].Trim()
                    Text = ($parts[1] + " " + $parts[2] + " " + $parts[3] + " " + $parts[4] + " " + $parts[5]).ToLower()
                    Path = "docs/memory/failure-journal.md"
                    Details = "Root Cause: $($parts[4].Trim()) | Invariant: $($parts[5].Trim())"
                }
            }
        }
    }
}

# 2. Harvest docs/memory/architectural-precedents.md
$precedentsPath = Join-Path $rootDir "docs\memory\architectural-precedents.md"
if (Test-Path $precedentsPath) {
    $lines = Get-Content $precedentsPath -Encoding UTF8
    foreach ($line in $lines) {
        if ($line.StartsWith("|") -and $line.Contains("ARC-")) {
            $parts = $line.Split("|")
            if ($parts.Count -ge 6) {
                $documents += [PSCustomObject]@{
                    Source = "Precedent"
                    ID = $parts[1].Trim()
                    Summary = $parts[3].Trim()
                    Text = ($parts[1] + " " + $parts[2] + " " + $parts[3] + " " + $parts[4] + " " + $parts[5]).ToLower()
                    Path = "docs/memory/architectural-precedents.md"
                    Details = "Standard: $($parts[4].Trim()) | Scope: $($parts[5].Trim())"
                }
            }
        }
    }
}

# 3. Harvest docs/decisions/*.md
$decisionsDir = Join-Path $rootDir "docs\decisions"
if (Test-Path $decisionsDir) {
    $files = Get-ChildItem -Path $decisionsDir -Filter "*.md" -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw -Encoding UTF8
        $documents += [PSCustomObject]@{
            Source = "ADR Decision"
            ID = $f.BaseName
            Summary = "Architecture Decision Record: $($f.BaseName)"
            Text = $content.ToLower()
            Path = "docs/decisions/$($f.Name)"
            Details = "Architecture decision record for $($f.BaseName)"
        }
    }
}

# BM25-Inspired Relevance Scoring
$scoredResults = @()
$avgDocLen = 40.0

foreach ($doc in $documents) {
    $docTokens = $doc.Text.Split(" `t`r`n,.-/\|:;()[]{}'`"", [System.StringSplitOptions]::RemoveEmptyEntries)
    $docLen = [double]$docTokens.Count
    if ($docLen -eq 0) { $docLen = 1.0 }

    $score = 0.0
    foreach ($qt in $queryTokens) {
        $count = 0
        foreach ($dt in $docTokens) {
            if ($dt -eq $qt) { $count += 2.0 }
            elseif ($dt.Contains($qt)) { $count += 1.0 }
        }
        if ($count -gt 0) {
            # BM25 TF component
            $tf = ($count * 2.2) / ($count + 1.2 * (0.25 + 0.75 * ($docLen / $avgDocLen)))
            $score += $tf * 3.0
        }
    }

    # Semantic synonym matches (bonus weight 1.5)
    foreach ($st in $expandedTokens) {
        if ($queryTokens -notcontains $st) {
            $synCount = 0
            foreach ($dt in $docTokens) {
                if ($dt -eq $st -or $dt.Contains($st)) { $synCount++ }
            }
            if ($synCount -gt 0) {
                $score += [math]::Min($synCount * 1.5, 4.0)
            }
        }
    }

    if ($score -gt 0) {
        $relevancePct = [math]::Min([math]::Round(($score / 15.0) * 100), 100)
        $scoredResults += [PSCustomObject]@{
            Source = $doc.Source
            ID = $doc.ID
            Score = $score
            RelevancePct = $relevancePct
            Summary = $doc.Summary
            Details = $doc.Details
            Path = $doc.Path
        }
    }
}

$sortedResults = @($scoredResults | Sort-Object -Property Score -Descending | Select-Object -First $Top)

if ($sortedResults.Count -eq 0) {
    Write-Host "[*] No matching memory entries found for: '$Query'" -ForegroundColor DarkGray
    exit 0
}

Write-Host "[OK] Found $($sortedResults.Count) relevant memory precedents:" -ForegroundColor Green
Write-Host ""

foreach ($r in $sortedResults) {
    $badgeColor = if ($r.RelevancePct -ge 75) { "Green" } elseif ($r.RelevancePct -ge 50) { "Yellow" } else { "DarkYellow" }
    Write-Host "[$($r.Source)] $($r.ID) (Relevance: $($r.RelevancePct)%)" -ForegroundColor $badgeColor
    Write-Host "  Path:    $($r.Path)" -ForegroundColor Gray
    Write-Host "  Summary: $($r.Summary)" -ForegroundColor White
    Write-Host "  Context: $($r.Details)" -ForegroundColor DarkGray
    Write-Host ""
}
