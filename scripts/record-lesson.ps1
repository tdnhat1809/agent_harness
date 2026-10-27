# ==============================================================================
# Failure Journal & Lesson Learned Recorder (PowerShell)
# Appends a structured postmortem entry into docs/memory/failure-journal.md
# ==============================================================================
param (
    [Parameter(Mandatory=$true)]
    [string]$Symptom,

    [Parameter(Mandatory=$true)]
    [string]$RootCause,

    [Parameter(Mandatory=$true)]
    [string]$Prevention,

    [string]$Details = ""
)

$ErrorActionPreference = "Stop"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$journalPath = "$rootDir\docs\memory\failure-journal.md"

if (-not (Test-Path $journalPath)) {
    Write-Error "Failure journal not found at: $journalPath"
    exit 1
}

$dateStr = Get-Date -Format "yyyy-MM-dd"
$content = Get-Content $journalPath -Raw -Encoding UTF8

# Find next ERR-XXX ID
$matches = [regex]::Matches($content, "ERR-(\d+)")
$maxId = 0
foreach ($m in $matches) {
    $val = [int]$m.Groups[1].Value
    if ($val -gt $maxId) { $maxId = $val }
}
$nextId = "ERR-{0:D3}" -f ($maxId + 1)
$codeId = '`' + $nextId + '`'

# Format table row
$newRow = "| $codeId | $dateStr | $Symptom | $RootCause | $Prevention |`n"

# Insert row into the table (right after table header)
$tableMarker = "|---|---|---|---|---|`n"
if ($content.Contains($tableMarker)) {
    $idx = $content.IndexOf($tableMarker) + $tableMarker.Length
    $content = $content.Substring(0, $idx) + $newRow + $content.Substring($idx)
} else {
    $content += "`n" + $newRow
}

# Append detailed section at end
$detailBlock = @"

### $($codeId): $Symptom
- **Date**: $dateStr
- **Symptom**: $Symptom
- **Root Cause**: $RootCause
- **Prevention Rule**: $Prevention
$(if ($Details) { "- **Details**: $Details`n" })
"@

$content += "`n" + $detailBlock

Set-Content -Path $journalPath -Value $content -Encoding UTF8
Write-Host "[Memory Guard] Successfully recorded lesson $nextId in docs/memory/failure-journal.md" -ForegroundColor Green
