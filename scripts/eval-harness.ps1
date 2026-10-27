# ==============================================================================
# AI Agent Harness Self-Regression Evaluation Benchmark (PowerShell)
# Tests and grades the entire harness across 4 empirical challenges
# ==============================================================================
param (
    [switch]$VerboseOutput
)

$ErrorActionPreference = "Continue"
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AI AGENT HARNESS SELF-REGRESSION BENCHMARK (EVAL)    " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$score = 0
$total = 100

# ------------------------------------------------------------------------------
# Challenge 1: Frontmatter & MCP Catalog Integrity (25 pts)
# ------------------------------------------------------------------------------
Write-Host "`n[Challenge 1/4] Frontmatter & Registry Integrity..." -ForegroundColor Yellow
$lintProc = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$rootDir\scripts\lint-harness.ps1`" -Strict" -NoNewWindow -PassThru -Wait

if ($lintProc.ExitCode -eq 0) {
    Write-Host "  [PASS] All skills, MCP servers, and hooks passed validation (+25 pts)" -ForegroundColor Green
    $score += 25
} else {
    Write-Host "  [FAIL] Integrity linter reported errors." -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# Challenge 2: Secret Shield Pre-Commit Rejection Test (25 pts)
# ------------------------------------------------------------------------------
Write-Host "`n[Challenge 2/4] Mechanical Secret Shield Defense Test..." -ForegroundColor Yellow
$tempTestRepo = Join-Path $env:TEMP "harness_eval_hook_test_$([Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    New-Item -ItemType Directory -Path "$tempTestRepo\.git\hooks" -Force | Out-Null
    
    # Init git
    $gitInit = Start-Process git -ArgumentList "init `"$tempTestRepo`"" -NoNewWindow -PassThru -Wait
    git -C $tempTestRepo config user.name "Eval Harness"
    git -C $tempTestRepo config user.email "eval@harness.local"
    
    # Install hook
    Copy-Item "$rootDir\scripts\git-hooks\pre-commit" "$tempTestRepo\.git\hooks\pre-commit" -Force
    
    # Stage a forbidden .env file
    Set-Content -Path "$tempTestRepo\.env" -Value "OPENAI_API_KEY=sk-abcdef1234567890abcdef1234567890"
    git -C $tempTestRepo add .env
    
    # Run git commit - it MUST be blocked
    $commitOutput = git -C $tempTestRepo commit -m "leaked secret" 2>&1
    $commitExit = $LASTEXITCODE

    if ($commitExit -ne 0) {
        Write-Host "  [PASS] Secret Shield successfully blocked .env credential commit (+25 pts)" -ForegroundColor Green
        $score += 25
    } else {
        Write-Host "  [FAIL] Secret Shield FAILED to block forbidden commit!" -ForegroundColor Red
    }
} finally {
    Remove-Item $tempTestRepo -Recurse -Force -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------------------
# Challenge 3: Anti-Blob & TDD Check Verification (25 pts)
# ------------------------------------------------------------------------------
Write-Host "`n[Challenge 3/4] Strict TDD Advisory & Anti-Blob Verification..." -ForegroundColor Yellow
$tempTestRepo2 = Join-Path $env:TEMP "harness_eval_tdd_test_$([Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    New-Item -ItemType Directory -Path "$tempTestRepo2\.git\hooks" -Force | Out-Null
    git -C $tempTestRepo2 init | Out-Null
    git -C $tempTestRepo2 config user.name "Eval Harness"
    git -C $tempTestRepo2 config user.email "eval@harness.local"
    Copy-Item "$rootDir\scripts\git-hooks\pre-commit" "$tempTestRepo2\.git\hooks\pre-commit" -Force

    # Create code file without test
    Set-Content -Path "$tempTestRepo2\service.py" -Value "def compute(): return 42"
    git -C $tempTestRepo2 add service.py
    
    Push-Location $tempTestRepo2
    try {
        $hookOutput = & "C:\Program Files\Git\bin\bash.exe" ".git\hooks\pre-commit" 2>&1
        if ($hookOutput -match "TDD ADVISORY") {
            Write-Host "  [PASS] Strict TDD guard correctly flagged missing test file (+25 pts)" -ForegroundColor Green
            $score += 25
        } else {
            Write-Host "  [WARN] TDD advisory check did not match expected output: $hookOutput" -ForegroundColor DarkYellow
        }
    } finally {
        Pop-Location
    }
} finally {
    Remove-Item $tempTestRepo2 -Recurse -Force -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------------------
# Challenge 4: Polyglot Test & Verify Execution (25 pts)
# ------------------------------------------------------------------------------
Write-Host "`n[Challenge 4/4] Polyglot Test & Verify Engine Test..." -ForegroundColor Yellow
$verifyProc = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$rootDir\scripts\verify.ps1`"" -NoNewWindow -PassThru -Wait

if ($verifyProc.ExitCode -eq 0) {
    Write-Host "  [PASS] Polyglot Verify runner executed with Exit Code 0 (+25 pts)" -ForegroundColor Green
    $score += 25
} else {
    Write-Host "  [FAIL] Verify runner returned non-zero exit code." -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# Final Benchmark Report
# ------------------------------------------------------------------------------
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "               FINAL HARNESS BENCHMARK SCORE            " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$grade = if ($score -ge 90) { "Grade A+ (Enterprise Production-Ready)" } elseif ($score -ge 75) { "Grade B (Usable)" } else { "Grade F (Needs Remediation)" }

Write-Host "  SCORE: $score / $total points" -ForegroundColor Yellow
Write-Host "  STATUS: $grade" -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Cyan

if ($score -lt 100) { exit 1 } else { exit 0 }
