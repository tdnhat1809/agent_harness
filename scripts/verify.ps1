# ==============================================================================
# Agent Harness Polyglot Test & Verification Engine (PowerShell)
# Enforces: Invariant 1 (Empirical Metrics) & Strict TDD Validation
# ==============================================================================
param (
    [string]$Command = "",
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT EMPIRICAL VERIFICATION RUNNER (VERIFY)     " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Auto-Detect Test Engine if not provided
if ([string]::IsNullOrWhiteSpace($Command)) {
    if (Test-Path "pnpm-lock.yaml") {
        $Command = "pnpm test"
    } elseif ((Test-Path "bun.lockb") -or (Test-Path "bun.lock")) {
        $Command = "bun test"
    } elseif (Test-Path "yarn.lock") {
        $Command = "yarn test"
    } elseif (Test-Path "package.json") {
        $Command = "npm test"
    } elseif (Test-Path "uv.lock") {
        $Command = "uv run pytest"
    } elseif (Test-Path "poetry.lock") {
        $Command = "poetry run pytest"
    } elseif ((Test-Path "pytest.ini") -or (Test-Path "pyproject.toml")) {
        $Command = "pytest"
    } elseif (Test-Path "go.mod") {
        $Command = "go test -v ./..."
    } elseif (Test-Path "Cargo.toml") {
        $Command = "cargo test"
    } elseif (Test-Path "*.sln") {
        $Command = "dotnet test"
    } elseif (Test-Path "pom.xml") {
        $Command = "mvn test"
    } elseif (Test-Path "build.gradle") {
        $Command = "gradle test"
    } elseif (Test-Path "Makefile") {
        $Command = "make test"
    } elseif (Test-Path "scripts\lint-harness.ps1") {
        $Command = "powershell -ExecutionPolicy Bypass -File .\scripts\lint-harness.ps1"
    } else {
        Write-Error "No recognized test runner found in current directory. Specify via: -Command '<cmd>'"
        exit 1
    }
}

Write-Host "`n[*] Executing Test Command: $Command" -ForegroundColor Yellow

# 2. Run Test Command and Capture Execution
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"$Command`""
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true

$proc = [System.Diagnostics.Process]::Start($psi)
$stdOut = $proc.StandardOutput.ReadToEnd()
$stdErr = $proc.StandardError.ReadToEnd()
$proc.WaitForExit()
$exitCode = $proc.ExitCode

$stopwatch.Stop()
$elapsed = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)

# 3. Output Results and Empirical Metrics
Write-Host "`n------------------- Output Stream -------------------" -ForegroundColor Gray
if ($Verbose -or $exitCode -ne 0) {
    if ($stdOut) { Write-Host $stdOut }
    if ($stdErr) { Write-Host $stdErr -ForegroundColor Red }
} else {
    # Print first and last few lines for brevity
    $lines = $stdOut -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $lines | Select-Object -First 8 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    if ($lines.Count -gt 16) {
        Write-Host "  ... [$($lines.Count - 16) lines omitted] ..." -ForegroundColor DarkGray
        $lines | Select-Object -Last 8 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
}
Write-Host "-----------------------------------------------------`n" -ForegroundColor Gray

# 4. Final Empirical Assessment
Write-Host "========================================================" -ForegroundColor Cyan
$defectMarker = "$PSScriptRoot\..\.agents\.defect_active"

if ($exitCode -eq 0) {
    Write-Host "✅ [VERIFY SUCCESS] Tests PASSED in ${elapsed}s (Exit Code: 0)" -ForegroundColor Green
    Write-Host "   Empirical evidence verified. Ready for sign-off." -ForegroundColor Green

    # Recency trigger: Alert agent if this run resolved a previously failing test
    if (Test-Path $defectMarker) {
        Remove-Item -Path $defectMarker -Force -ErrorAction SilentlyContinue
        Write-Host ""
        Write-Host "🔔 [HARNESS EXPERIENCE MANDATE] A previously failing test/defect has been resolved!" -ForegroundColor Magenta
        Write-Host "   Invariant 6 & Mandate 5 strictly require persisting the root cause and invariant lesson." -ForegroundColor Yellow
        Write-Host "   👉 RUN NOW: powershell -ExecutionPolicy Bypass -File .\scripts\record-lesson.ps1" -ForegroundColor Cyan
        Write-Host "   Note: Git 'commit-msg' hook will mechanically REJECT any fix commit without failure-journal.md." -ForegroundColor DarkYellow
        Write-Host ""
    }
} else {
    Write-Host "❌ [VERIFY FAILURE] Tests FAILED in ${elapsed}s (Exit Code: $exitCode)" -ForegroundColor Red
    Write-Host "   Strict Invariant Mandate: Fix root cause before claiming completion." -ForegroundColor Yellow

    # Mark active defect for dynamic recency reminder
    try {
        Set-Content -Path $defectMarker -Value "FAIL|$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')|$Command" -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
}
Write-Host "========================================================`n" -ForegroundColor Cyan

exit $exitCode
