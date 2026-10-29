<#
.SYNOPSIS
    Flaky Test Isolator & Bisection Engine.
.DESCRIPTION
    Runs a specified test command multiple times in rapid succession to detect
    non-deterministic test behavior, calculates the flake rate, and isolates/quarantines
    the test to prevent agent loops and hallucinations.
.PARAMETER Command
    The exact test command to execute.
.PARAMETER Iterations
    Number of repetitions to run (default: 5).
.PARAMETER Quarantine
    If flaky, automatically appends entry to docs/memory/quarantined-tests.md.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Command,

    [Parameter(Position = 1)]
    [int]$Iterations = 5,

    [Parameter()]
    [switch]$Quarantine
)

$ErrorActionPreference = "Continue"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   FLAKY TEST ISOLATOR & BISECTION ENGINE               " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "[*] Target Command: $Command" -ForegroundColor Yellow
Write-Host "[*] Iterations:     $Iterations" -ForegroundColor Gray

$passed = 0
$failed = 0
$durations = @()

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host -NoNewline "  [Run $i/$Iterations] Executing... " -ForegroundColor Gray
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    
    $global:LASTEXITCODE = 0
    $out = Invoke-Expression $Command 2>&1
    $exitCode = if ($null -ne $global:LASTEXITCODE) { $global:LASTEXITCODE } else { 0 }
    if (-not $?) { $exitCode = 1 }
    
    $sw.Stop()
    $durations += $sw.Elapsed.TotalSeconds

    if ($exitCode -eq 0) {
        $passed++
        Write-Host "PASS ($([math]::Round($sw.Elapsed.TotalSeconds, 2))s)" -ForegroundColor Green
    } else {
        $failed++
        Write-Host "FAIL ($([math]::Round($sw.Elapsed.TotalSeconds, 2))s, Exit Code: $exitCode)" -ForegroundColor Red
    }
}

$avgDuration = [math]::Round(($durations | Measure-Object -Average).Average, 2)
$flakeRate = [math]::Round(($failed / $Iterations) * 100, 1)

Write-Host ""
Write-Host "--- Execution Summary ---" -ForegroundColor Cyan
Write-Host "Total Runs:  $Iterations" -ForegroundColor Gray
Write-Host "Passed:      $passed" -ForegroundColor Green
Write-Host "Failed:      $failed" -ForegroundColor Red
Write-Host "Avg Time:    ${avgDuration}s per run" -ForegroundColor Gray

if ($passed -eq $Iterations) {
    Write-Host "[RESULT] CONSISTENT GREEN (100% Pass Rate). Test is deterministic and stable." -ForegroundColor Green
    exit 0
}
elseif ($failed -eq $Iterations) {
    Write-Host "[RESULT] CONSISTENT RED (100% Fail Rate). True defect detected. Not a flaky test." -ForegroundColor Red
    exit 1
}
else {
    Write-Host "[RESULT] FLAKY TEST DETECTED (Flake Rate: ${flakeRate}%)." -ForegroundColor DarkYellow
    Write-Host "  Advisory: Non-deterministic behavior identified (timing, async, or unseeded state)." -ForegroundColor Yellow

    if ($Quarantine) {
        $rootDir = (Resolve-Path "$PSScriptRoot\..").Path
        $quarantineFile = Join-Path $rootDir "docs\memory\quarantined-tests.md"
        $qDir = Split-Path $quarantineFile -Parent
        if (-not (Test-Path $qDir)) { New-Item -ItemType Directory -Path $qDir -Force | Out-Null }

        if (-not (Test-Path $quarantineFile)) {
            $header = @(
                "# Quarantined Flaky Tests Register",
                "",
                "This register tracks non-deterministic tests quarantined to protect agents from regression loops.",
                "",
                "| Quarantined Date | Test Command | Flake Rate | Iterations | Status | Action Required |",
                "|---|---|---|---|---|---|"
            )
            Set-Content -Path $quarantineFile -Value ($header -join "`n") -Encoding UTF8
        }

        $dateStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $sanitizedCmd = $Command.Replace("|", "\/")
        $entry = "| {0} | `{1}` | {2}% | {3} | QUARANTINED | Isolate shared state / mock timer |" -f $dateStr, $sanitizedCmd, $flakeRate, $Iterations
        Add-Content -Path $quarantineFile -Value $entry -Encoding UTF8
        Write-Host "  [QUARANTINED] Recorded into docs/memory/quarantined-tests.md" -ForegroundColor Cyan
    }

    exit 2
}
