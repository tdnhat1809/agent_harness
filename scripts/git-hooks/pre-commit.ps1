# ==============================================================================
# Agent Harness Mechanical Pre-Commit Gate for Windows (PowerShell)
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "🛡️  [Harness Guard] Running pre-commit validation (PowerShell)..." -ForegroundColor Cyan

# 1. Secret & Sensitive File Shield
$stagedFiles = git diff --cached --name-only
$forbiddenPatterns = @(
    '^\.env(\..+)?$',
    '\.pem$',
    '\.key$',
    'id_rsa$',
    'id_ed25519$',
    'credentials\.json$',
    '\.pfx$'
)

$leakedFiles = @()
foreach ($file in $stagedFiles) {
    foreach ($pat in $forbiddenPatterns) {
        if ($file -match $pat) {
            $leakedFiles += $file
            break
        }
    }
}

if ($leakedFiles.Count -gt 0) {
    Write-Host "❌ [SECURITY REJECTED] Sensitive or credential files detected in staged changes:" -ForegroundColor Red
    $leakedFiles | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    Write-Host "Remove them using: git reset HEAD <file>" -ForegroundColor Yellow
    exit 1
}

# 2. Secret Pattern Scanner in Diff
$diff = git diff --cached -U0
$secretPatterns = @(
    'ghp_[a-zA-Z0-9]{36}',
    'sk-[a-zA-Z0-9]{32,}',
    'AKIA[0-9A-Z]{16}',
    'AIza[0-9A-Za-z-_]{35}',
    'BEGIN PRIVATE KEY'
)

foreach ($sp in $secretPatterns) {
    if ($diff -match $sp) {
        Write-Host "❌ [SECURITY REJECTED] High-entropy API key or private key pattern detected in staged diff!" -ForegroundColor Red
        Write-Host "Aborting commit to prevent credential leak." -ForegroundColor Red
        exit 1
    }
}

# 3. Strict TDD Check
$codeFiles = @($stagedFiles | Where-Object { $_ -match '\.(ts|tsx|js|jsx|py|go|rs|java|cs|cpp|c)$' })
$testFiles = @($stagedFiles | Where-Object { $_ -match '(test|spec|tests|_test|test_)' })

if ($codeFiles.Count -gt 0 -and $testFiles.Count -eq 0) {
    Write-Host "⚠️  [TDD ADVISORY] Source code changed without corresponding test files staged:" -ForegroundColor Yellow
    $codeFiles | Select-Object -First 5 | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
    Write-Host "    -> Strict TDD Mandate requires automated tests proving FAIL (RED) then PASS (GREEN)." -ForegroundColor Yellow
}

Write-Host "✅ [Harness Guard] Pre-commit checks passed successfully." -ForegroundColor Green
exit 0
