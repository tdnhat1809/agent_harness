<#
.SYNOPSIS
    Visual UI & Design System Auditor (Zero-Emoji & Anti-AI Slop Gate).
.DESCRIPTION
    Scans UI files (HTML, JSX, TSX, Vue, Svelte) to mechanically enforce:
    1. Zero-Emoji Icon Policy in UI elements (buttons, badges, nav).
    2. Ban on cliché AI purple gradients (from-purple-500 to-indigo-600).
    3. Accessibility (a11y) WCAG standards (alt tags, aria-labels for icon buttons).
    4. Design tokens compliance (neutral zinc/slate palette).
.PARAMETER Path
    Path to file or directory to audit (defaults to current directory).
.PARAMETER Strict
    Fails with exit code 1 if any AI slop or accessibility violation is found.
.PARAMETER ScreenshotUrl
    Optional URL or HTML path to capture via headless browser if available.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Target = ".",

    [Parameter()]
    [switch]$Strict,

    [Parameter()]
    [string]$ScreenshotUrl = ""
)

$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   VISUAL UI & DESIGN SYSTEM AUDITOR (ANTI-AI SLOP)    " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$emojiPattern = '([\uD83C-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF])'
$purpleGradientPattern = '(from-purple-\d+|to-indigo-\d+|from-violet-\d+|to-purple-\d+|bg-gradient-to-r\s+from-purple)'

$violations = @()
$filesAudited = 0

# Collect files to audit
$fileExtensions = @("*.html", "*.jsx", "*.tsx", "*.vue", "*.svelte")
$filesToScan = @()

if (Test-Path $Target -PathType Leaf) {
    $filesToScan += (Get-Item $Target)
} elseif (Test-Path $Target -PathType Container) {
    foreach ($ext in $fileExtensions) {
        $filesToScan += (Get-ChildItem -Path $Target -Filter $ext -Recurse -File -ErrorAction SilentlyContinue | 
            Where-Object { $_.FullName -notmatch '[\\/](node_modules|\.git|dist|build|\.next|\.gemini)[\\/]' })
    }
}

Write-Host "[*] Auditing $($filesToScan.Count) UI components in '$Target'..." -ForegroundColor Gray

foreach ($file in $filesToScan) {
    $filesAudited++
    $lines = Get-Content -Path $file.FullName
    $lineNum = 0

    foreach ($line in $lines) {
        $lineNum++

        # Check 1: Zero-Emoji Icon Policy
        if ($line -match $emojiPattern) {
            $matchedEmoji = $Matches[0]
            # Exclude code comments or documentation blocks if desired, but in UI code emojis in JSX/HTML are banned
            $violations += [PSCustomObject]@{
                File = $file.FullName.Replace((Get-Location).Path, "").TrimStart("\/")
                Line = $lineNum
                Type = "AI-SLOP-EMOJI"
                Severity = "Critical"
                Message = "Raw emoji icon detected: '$matchedEmoji'. Replace with industrial SVG icon (Lucide / Heroicons)."
                Snippet = $line.Trim()
            }
        }

        # Check 2: Cliché AI Purple Gradient Slop
        if ($line -match $purpleGradientPattern) {
            $violations += [PSCustomObject]@{
                File = $file.FullName.Replace((Get-Location).Path, "").TrimStart("\/")
                Line = $lineNum
                Type = "AI-SLOP-GRADIENT"
                Severity = "High"
                Message = "Cliche AI purple gradient detected ('$($Matches[0])'). Use Neutral Zinc/Slate design tokens."
                Snippet = $line.Trim()
            }
        }

        # Check 3: Accessibility - Images missing alt attribute
        if ($line -match '<img\b(?![^>]*\balt=)' -and $line -notmatch 'alt=""') {
            $violations += [PSCustomObject]@{
                File = $file.FullName.Replace((Get-Location).Path, "").TrimStart("\/")
                Line = $lineNum
                Type = "A11Y-MISSING-ALT"
                Severity = "Medium"
                Message = "Image tag missing 'alt' attribute for screen reader accessibility."
                Snippet = $line.Trim()
            }
        }

        # Check 4: Accessibility - Icon buttons missing aria-label
        if ($line -match '<button\b(?![^>]*\baria-label=)' -and $line -match '<(svg|Lucide|Icon)') {
            $violations += [PSCustomObject]@{
                File = $file.FullName.Replace((Get-Location).Path, "").TrimStart("\/")
                Line = $lineNum
                Type = "A11Y-ICON-BUTTON"
                Severity = "Medium"
                Message = "Icon button missing 'aria-label' attribute."
                Snippet = $line.Trim()
            }
        }
    }
}

# 5. Headless Browser Check if requested and node/playwright or chrome available
if ($ScreenshotUrl -ne "") {
    Write-Host "[*] Triggering Headless Browser Inspection on '$ScreenshotUrl'..." -ForegroundColor Cyan
    $outputDir = "$PSScriptRoot\..\docs\screenshots"
    if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $shotPath = "$outputDir\ui-audit-$timestamp.png"

    # Try headless chrome / msedge
    $edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    $chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    $browserExe = $null
    if (Test-Path $edgePath) { $browserExe = $edgePath }
    elseif (Test-Path $chromePath) { $browserExe = $chromePath }

    if ($browserExe) {
        Write-Host "  [Browser] Capturing headless screenshot via $browserExe..." -ForegroundColor Gray
        Start-Process -FilePath $browserExe -ArgumentList @(
            "--headless=new",
            "--disable-gpu",
            "--window-size=1280,800",
            "--screenshot=`"$shotPath`"",
            "`"$ScreenshotUrl`""
        ) -Wait -NoNewWindow
        if (Test-Path $shotPath) {
            Write-Host "  [OK] Visual screenshot captured: $shotPath" -ForegroundColor Green
        }
    } else {
        Write-Host "  [SKIP] No headless browser executable detected on system." -ForegroundColor Yellow
    }
}

# Summary Report
Write-Host ""
Write-Host "--- Audit Results ---" -ForegroundColor Cyan
Write-Host "Files Scanned: $filesAudited" -ForegroundColor Gray
$vCountColor = if ($violations.Count -gt 0) { "Yellow" } else { "Green" }
Write-Host "Violations Found: $($violations.Count)" -ForegroundColor $vCountColor

if ($violations.Count -gt 0) {
    Write-Host ""
    foreach ($v in $violations) {
        $color = if ($v.Severity -eq "Critical") { "Red" } elseif ($v.Severity -eq "High") { "DarkYellow" } else { "Yellow" }
        Write-Host "[$($v.Severity)] $($v.File):$($v.Line) - $($v.Type)" -ForegroundColor $color
        Write-Host "  Issue:   $($v.Message)" -ForegroundColor Gray
        Write-Host "  Snippet: $($v.Snippet)" -ForegroundColor DarkGray
    }
    Write-Host ""
    if ($Strict) {
        Write-Host "[FAIL] UI Audit failed under -Strict mode. Clean all AI slop before proceeding." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "[WARN] UI Audit detected $($violations.Count) non-compliant elements." -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "[PASS] Zero AI slop detected. UI compliant with Anti-Emoji and Design Token rules." -ForegroundColor Green
    exit 0
}
