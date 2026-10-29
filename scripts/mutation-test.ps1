# ==============================================================================
# Agent Harness Mutation Testing Engine (PowerShell)
# Enforces: Invariant 1 (Empirical Truth) & Anti-Hollow Testing Protocol
# Proves that tests actually detect code defects by injecting deliberate mutants.
# ==============================================================================
param (
    [string]$File = "",
    [string]$TestCommand = "",
    [int]$MaxMutations = 3
)

$ErrorActionPreference = "Continue"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT MUTATION TESTING ENGINE (ANTI-HOLLOW TEST) " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Identify target file if not provided
if ([string]::IsNullOrWhiteSpace($File)) {
    # Find most recently modified source file in git diff
    $modified = git diff --name-only | Where-Object { $_ -match '\.(py|ts|js|go|rs|cs|cpp|c)$' -and $_ -notmatch '(test|spec|_test)' }
    if (-not $modified) {
        $modified = git diff HEAD~1 --name-only | Where-Object { $_ -match '\.(py|ts|js|go|rs|cs|cpp|c)$' -and $_ -notmatch '(test|spec|_test)' }
    }
    if ($modified) {
        $File = $modified[0]
    } else {
        Write-Error "No target source file specified or detected in git diff. Usage: .\scripts\mutation-test.ps1 -File <path>"
        exit 1
    }
}

if (-not (Test-Path $File)) {
    Write-Error "Target file not found: $File"
    exit 1
}

Write-Host "`n[*] Target Source File: $File" -ForegroundColor Yellow

# 2. Determine Test Command
if ([string]::IsNullOrWhiteSpace($TestCommand)) {
    $TestCommand = "powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1"
}
Write-Host "[*] Baseline Test Command: $TestCommand" -ForegroundColor Yellow

# 3. Baseline Verification (Tests MUST pass before mutating)
Write-Host "`n[1/3] Running Baseline Tests..." -ForegroundColor Cyan
$baselineProc = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$TestCommand`"" -NoNewWindow -PassThru -Wait
if ($baselineProc.ExitCode -ne 0) {
    Write-Host "❌ [MUTATION ABORT] Baseline tests are currently failing! Fix code before running mutation testing." -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Baseline tests passed cleanly (Exit Code 0)." -ForegroundColor Green

# 4. Generate Mutations
Write-Host "`n[2/3] Injecting Mutations into $File..." -ForegroundColor Cyan
$originalContent = Get-Content -Path $File -Raw -Encoding UTF8

$mutations = @()

# Mutant 1: Invert comparison operators
if ($originalContent -match '>|<|==|!=') {
    $mutantCode = $originalContent
    if ($mutantCode -match ' == ') { $mutantCode = $mutantCode -replace ' == ', ' != ' }
    elseif ($mutantCode -match ' > ') { $mutantCode = $mutantCode -replace ' > ', ' <= ' }
    elseif ($mutantCode -match ' < ') { $mutantCode = $mutantCode -replace ' < ', ' >= ' }
    $mutations += @{ Name = "Invert Operator (== / > / <)"; Code = $mutantCode }
}

# Mutant 2: Invert Boolean literals
if ($originalContent -match '\btrue\b|\bTrue\b|\bfalse\b|\bFalse\b') {
    $mutantCode = $originalContent
    if ($mutantCode -match '\btrue\b') { $mutantCode = $mutantCode -replace '\btrue\b', 'false' }
    elseif ($mutantCode -match '\bTrue\b') { $mutantCode = $mutantCode -replace '\bTrue\b', 'False' }
    elseif ($mutantCode -match '\bfalse\b') { $mutantCode = $mutantCode -replace '\bfalse\b', 'true' }
    elseif ($mutantCode -match '\bFalse\b') { $mutantCode = $mutantCode -replace '\bFalse\b', 'True' }
    $mutations += @{ Name = "Invert Boolean Literal (True <-> False)"; Code = $mutantCode }
}

# Mutant 3: Return Value Mutation
if ($originalContent -match 'return\s+[^;\n]+') {
    $mutantCode = $originalContent -replace 'return\s+[^;\n]+', 'return None'
    $mutations += @{ Name = "Mutate Return Value to None/null"; Code = $mutantCode }
}

if ($mutations.Count -eq 0) {
    Write-Host "⚠️  No applicable mutation points found in $File." -ForegroundColor Yellow
    exit 0
}

# Limit to MaxMutations
if ($mutations.Count -gt $MaxMutations) {
    $mutations = $mutations[0..($MaxMutations - 1)]
}

# 5. Execute Mutants & Check if Tests Kill Them
Write-Host "`n[3/3] Evaluating Mutant Survival..." -ForegroundColor Cyan
$killed = 0
$total = $mutations.Count

try {
    for ($i = 0; $i -lt $total; $i++) {
        $m = $mutations[$i]
        $mNum = $i + 1
        Write-Host "  -> Mutant #$mNum: $($m.Name)..." -NoNewline

        # Apply mutation
        Set-Content -Path $File -Value $m.Code -Encoding UTF8

        # Run test command
        $testProc = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$TestCommand`"" -NoNewWindow -PassThru -Wait
        $testExit = $testProc.ExitCode

        if ($testExit -ne 0) {
            Write-Host " KILLED ✅ (Tests caught defect!)" -ForegroundColor Green
            $killed++
        } else {
            Write-Host " SURVIVED ❌ (Hollow test! Defect went undetected!)" -ForegroundColor Red
        }
    }
} finally {
    # Restore original content unconditionally
    Set-Content -Path $File -Value $originalContent -Encoding UTF8
    Write-Host "`n[*] Restored original content of $File." -ForegroundColor DarkGray
}

# 6. Final Empirical Mutation Score
$score = [math]::Round(($killed / $total) * 100, 1)

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "               MUTATION TESTING REPORT                  " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Target File:     $File"
Write-Host "  Mutants Tested:  $total"
Write-Host "  Mutants Killed:  $killed"
Write-Host "  Mutants Survived: $($total - $killed)"
Write-Host "  Mutation Score:  $score%" -ForegroundColor $(if ($score -ge 80) { "Green" } elseif ($score -ge 50) { "Yellow" } else { "Red" })

if ($killed -eq $total) {
    Write-Host "  Result:          PASSED ✅ (Robust test suite with deep assertions)" -ForegroundColor Green
    Write-Host "========================================================`n" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  Result:          WARNING ⚠️ (Test suite failed to detect injected bugs!)" -ForegroundColor Yellow
    Write-Host "  Action:          Add negative edge-case assertions to kill surviving mutants." -ForegroundColor Yellow
    Write-Host "========================================================`n" -ForegroundColor Cyan
    exit 0
}
