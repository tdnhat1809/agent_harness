# ==============================================================================
# Universal AI Agent Harness & Skills Framework Installer for Windows (PowerShell)
# Supports: Antigravity IDE, Claude CLI (Claude Code), Codex, OpenCode, Cursor, Windsurf, Copilot
# ==============================================================================
param (
    [string]$Target = "",
    [ValidateSet("all", "minimal", "web-fullstack", "security-re", "auto")]
    [string]$Profile = "auto"
)

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   UNIVERSAL AI AGENT HARNESS & SKILLS FRAMEWORK       " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$sourceDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Target)) {
    if (Test-Path "$sourceDir\..\.git" -or Test-Path "$sourceDir\..\package.json" -or Test-Path "$sourceDir\..\go.mod" -or Test-Path "$sourceDir\..\Cargo.toml" -or Test-Path "$sourceDir\..\pyproject.toml") {
        $Target = (Resolve-Path "$sourceDir\..").Path
        Write-Host "[Auto-Detected] Installing into parent project root: $Target" -ForegroundColor Cyan
    } else {
        $Target = (Get-Location).Path
    }
}

if (-not (Test-Path $Target)) {
    Write-Error "Target directory does not exist: $Target"
    exit 1
}

# Auto-Detect Profile if set to "auto"
if ($Profile -eq "auto") {
    $hasBinary = (Get-ChildItem -Path $Target -Include "*.exe","*.dll","*.bin","*.so","*.apk","*.ipa" -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1)
    $hasWebOrBackend = (Test-Path "$Target\package.json") -or (Test-Path "$Target\pyproject.toml") -or (Test-Path "$Target\requirements.txt") -or (Test-Path "$Target\go.mod") -or (Test-Path "$Target\Cargo.toml")
    
    if ($hasBinary) {
        $Profile = "security-re"
        Write-Host "[Auto-Profile] Binary / target artifacts detected -> Using Profile: security-re" -ForegroundColor Yellow
    } elseif ($hasWebOrBackend) {
        $Profile = "web-fullstack"
        Write-Host "[Auto-Profile] Web / Backend stack detected -> Using Profile: web-fullstack" -ForegroundColor Yellow
    } else {
        $Profile = "all"
        Write-Host "[Auto-Profile] General polyglot environment -> Using Profile: all" -ForegroundColor Yellow
    }
} else {
    Write-Host "[Configured] Selected Profile: $Profile" -ForegroundColor Yellow
}

Write-Host "`n[*] Installing into: $Target" -ForegroundColor Yellow

# 1. Ensure target subdirectories exist
$dirsToCreate = @(
    "$Target\.agents\rules",
    "$Target\.agents\plugins",
    "$Target\.agents\skills",
    "$Target\.agents\roles",
    "$Target\.agents\workflows",
    "$Target\.claude\commands",
    "$Target\.cursor\rules",
    "$Target\.github\workflows",
    "$Target\docs\plans\active",
    "$Target\docs\plans\completed",
    "$Target\docs\decisions",
    "$Target\docs\patterns",
    "$Target\docs\templates",
    "$Target\docs\runbooks",
    "$Target\docs\memory",
    "$Target\scripts\git-hooks"
)

foreach ($d in $dirsToCreate) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

# 2. Copy .agents directory (hooks, mcp, rules, plugins, roles, workflows)
Write-Host "[+] Copying .agents (hooks, rules, plugins, roles, workflows)..." -ForegroundColor Green
Copy-Item "$sourceDir\.agents\hooks.json" "$Target\.agents\hooks.json" -Force
Copy-Item "$sourceDir\.agents\mcp_config.json" "$Target\.agents\mcp_config.json" -Force
if (Test-Path "$sourceDir\.agents\mcp_catalog.json") {
    Copy-Item "$sourceDir\.agents\mcp_catalog.json" "$Target\.agents\mcp_catalog.json" -Force
}
Copy-Item "$sourceDir\.agents\rules\*" "$Target\.agents\rules\" -Recurse -Force
Copy-Item "$sourceDir\.agents\plugins\*" "$Target\.agents\plugins\" -Recurse -Force
if (Test-Path "$sourceDir\.agents\roles") {
    Copy-Item "$sourceDir\.agents\roles\*" "$Target\.agents\roles\" -Recurse -Force
}
if (Test-Path "$sourceDir\.agents\workflows") {
    Copy-Item "$sourceDir\.agents\workflows\*" "$Target\.agents\workflows\" -Recurse -Force
}

# 2.1 Profile-Based Skill Installation
Write-Host "[+] Installing Skills for Profile [$Profile]..." -ForegroundColor Green

$minimalSkills = @(
    'verification-before-completion', 'test-driven-development', 'systematic-debugging',
    'empirical-evidence-guard', 'encode-invariant', 'writing-plans', 'workflow-plan',
    'workflow-feature-dev', 'workflow-code-review', 'workflow-build-fix',
    'workflow-quality-gate', 'workflow-pr', 'caveman', 'ponytail', 'brainstorming',
    'docs-generator'
)

$webSkills = $minimalSkills + @(
    'vercel-react-best-practices', 'python-engineering', 'go-engineering',
    'rust-engineering', 'database-migrations-design', 'docker-devops-ci',
    'web-design-guidelines', 'design-taste', 'impeccable-design', 'api-security',
    'code-audit', 'subagent-driven-development', 'diagram-generator', 'engineering-wisdom'
)

$securitySkills = $minimalSkills + @(
    'reverse-engineer-anything', 'rea-analysis-optimization', 'rea-changelog-update',
    'rea-ci-tests-audit', 'rea-tool-design', 'reverse-engineering', 'reverse-skill-router',
    'ida-reverse', 'ghidra-reverse', 'radare2', 'apk-reverse', 'mobile-reverse',
    'dotnet-reverse', 'macos-reverse', 'go-rust-reverse', 'protocol-reverse',
    'js-reverse', 'binary-diff', 'patch-diff-exploit', 'pwn-chain', 'edr-bypass-re',
    'firmware-pentest', 'hardware-security', 'digital-forensics', 'malware-analysis',
    'pentest-tools', 'api-security', 'cloud-k8s', 'database-security', 'windows-ad',
    'wifi-wireless', 'email-security', 'llm-security', 'threat-hunting',
    'browser-automation', 'browser-extension-reverse', 'case-review', 'thick-client',
    'radio-sdr', 'ot-ics'
)

# Always copy root metadata files in .agents/skills
Get-ChildItem -Path "$sourceDir\.agents\skills\*" -File | ForEach-Object {
    Copy-Item $_.FullName "$Target\.agents\skills\" -Force
}
if (Test-Path "$sourceDir\.agents\skills\scripts") {
    Copy-Item "$sourceDir\.agents\skills\scripts" "$Target\.agents\skills\" -Recurse -Force
}

if ($Profile -eq "all") {
    Copy-Item "$sourceDir\.agents\skills\*" "$Target\.agents\skills\" -Recurse -Force
} else {
    $targetSkills = if ($Profile -eq "minimal") { $minimalSkills } elseif ($Profile -eq "web-fullstack") { $webSkills } else { $securitySkills }
    foreach ($sk in $targetSkills) {
        $skPath = "$sourceDir\.agents\skills\$sk"
        if (Test-Path $skPath) {
            Copy-Item $skPath "$Target\.agents\skills\" -Recurse -Force
        }
    }
}

# 3. Copy .claude slash commands (/plan, /tdd, /review, /verify, /build-fix)
if (Test-Path "$sourceDir\.claude\commands") {
    Write-Host "[+] Copying Claude Code slash commands (.claude/commands)..." -ForegroundColor Green
    Copy-Item "$sourceDir\.claude\commands\*" "$Target\.claude\commands\" -Recurse -Force
}

# 4. Copy docs directory (HARNESS.md, INVARIANTS.md, WORKFLOW.md, patterns, templates, decisions, scratchpad)
Write-Host "[+] Copying docs (HARNESS, INVARIANTS, WORKFLOW, patterns, templates, decisions, scratchpad)..." -ForegroundColor Green
Copy-Item "$sourceDir\docs\HARNESS.md" "$Target\docs\HARNESS.md" -Force
if (Test-Path "$sourceDir\docs\INVARIANTS.md") {
    Copy-Item "$sourceDir\docs\INVARIANTS.md" "$Target\docs\INVARIANTS.md" -Force
}
Copy-Item "$sourceDir\docs\WORKFLOW.md" "$Target\docs\WORKFLOW.md" -Force
if (Test-Path "$sourceDir\docs\scratchpad.md") { Copy-Item "$sourceDir\docs\scratchpad.md" "$Target\docs\scratchpad.md" -Force }
Copy-Item "$sourceDir\docs\patterns\*" "$Target\docs\patterns\" -Recurse -Force
Copy-Item "$sourceDir\docs\templates\*" "$Target\docs\templates\" -Recurse -Force
if (Test-Path "$sourceDir\docs\decisions") { Copy-Item "$sourceDir\docs\decisions\*" "$Target\docs\decisions\" -Recurse -Force }
if (Test-Path "$sourceDir\docs\memory") { Copy-Item "$sourceDir\docs\memory\*" "$Target\docs\memory\" -Recurse -Force }

# 5. Copy Cursor .mdc rules and scripts
if (Test-Path "$sourceDir\.cursor\rules") {
    Copy-Item "$sourceDir\.cursor\rules\*" "$Target\.cursor\rules\" -Recurse -Force
}
if (Test-Path "$sourceDir\scripts") {
    Copy-Item "$sourceDir\scripts\*" "$Target\scripts\" -Recurse -Force
}

# Ensure .gitkeep in plans & runbooks
New-Item -ItemType File -Path "$Target\docs\plans\active\.gitkeep" -Force | Out-Null
New-Item -ItemType File -Path "$Target\docs\plans\completed\.gitkeep" -Force | Out-Null
New-Item -ItemType File -Path "$Target\docs\runbooks\.gitkeep" -Force | Out-Null

# 6. Smart Merge / Copy for Context Entrypoints
function Merge-Or-Create-File ($srcFile, $dstFile, $label) {
    if (-not (Test-Path $dstFile)) {
        Write-Host "[+] Creating new $label..." -ForegroundColor Green
        Copy-Item $srcFile $dstFile -Force
    } else {
        $existing = Get-Content $dstFile -Raw
        if ($existing -notmatch "<!-- HARNESS:BEGIN -->") {
            Write-Host "[+] Appending Harness block to existing $label..." -ForegroundColor Yellow
            $sourceContent = Get-Content $srcFile -Raw
            $blockMatch = [regex]::Match($sourceContent, "(?s)<!-- HARNESS:BEGIN -->.*?<!-- HARNESS:END -->")
            if ($blockMatch.Success) {
                Add-Content -Path $dstFile -Value ("`n`n" + $blockMatch.Value + "`n")
                Write-Host "    -> $label merged safely!" -ForegroundColor Green
            }
        } else {
            Write-Host "[i] $label already contains Harness block. Skipping." -ForegroundColor Gray
        }
    }
}

Merge-Or-Create-File "$sourceDir\AGENTS.md" "$Target\AGENTS.md" "AGENTS.md"
Merge-Or-Create-File "$sourceDir\CLAUDE.md" "$Target\CLAUDE.md" "CLAUDE.md (Claude Code)"
Merge-Or-Create-File "$sourceDir\CODEX.md" "$Target\CODEX.md" "CODEX.md (Codex)"
Merge-Or-Create-File "$sourceDir\OPENCODE.md" "$Target\OPENCODE.md" "OPENCODE.md (OpenCode)"
if (Test-Path "$sourceDir\GEMINI.md") {
    Merge-Or-Create-File "$sourceDir\GEMINI.md" "$Target\GEMINI.md" "GEMINI.md (Antigravity / Gemini)"
}

# 7. IDE Rules & Ignore Files
if (-not (Test-Path "$Target\.cursorrules")) { Copy-Item "$sourceDir\.cursorrules" "$Target\.cursorrules" -Force }
if (-not (Test-Path "$Target\.windsurfrules")) { Copy-Item "$sourceDir\.windsurfrules" "$Target\.windsurfrules" -Force }
if (-not (Test-Path "$Target\.cursorignore")) { Copy-Item "$sourceDir\.cursorignore" "$Target\.cursorignore" -Force }
if (-not (Test-Path "$Target\.claudeignore")) { Copy-Item "$sourceDir\.claudeignore" "$Target\.claudeignore" -Force }
if (-not (Test-Path "$Target\.agentignore")) { Copy-Item "$sourceDir\.agentignore" "$Target\.agentignore" -Force }
if (-not (Test-Path "$Target\.github\copilot-instructions.md")) { Copy-Item "$sourceDir\.github\copilot-instructions.md" "$Target\.github\copilot-instructions.md" -Force }
if (-not (Test-Path "$Target\.github\PULL_REQUEST_TEMPLATE.md")) { Copy-Item "$sourceDir\.github\PULL_REQUEST_TEMPLATE.md" "$Target\.github\PULL_REQUEST_TEMPLATE.md" -Force }

# 8. Mechanical Git Hooks Installation
if (Test-Path "$Target\.git\hooks") {
    Write-Host "[+] Installing Mechanical Git Hooks into $Target\.git\hooks..." -ForegroundColor Green
    Copy-Item "$sourceDir\scripts\git-hooks\pre-commit" "$Target\.git\hooks\pre-commit" -Force
    Copy-Item "$sourceDir\scripts\git-hooks\pre-push" "$Target\.git\hooks\pre-push" -Force
}

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   UNIVERSAL INSTALLATION COMPLETED SUCCESSFULLY!      " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Installed Profile: $Profile" -ForegroundColor Yellow
Write-Host "Compatible with:"
Write-Host "  - Antigravity IDE (via AGENTS.md + .agents/hooks.json)"
Write-Host "  - Claude CLI / Claude Code (via CLAUDE.md + .claude/commands/)"
Write-Host "  - OpenAI Codex & ChatGPT CLI (via CODEX.md + AGENTS.md)"
Write-Host "  - OpenCode Harness (via OPENCODE.md + AGENTS.md)"
Write-Host "  - Cursor IDE (via .cursorrules + .cursorignore)"
Write-Host "  - Windsurf IDE (via .windsurfrules)"
Write-Host "  - GitHub Copilot (via .github/copilot-instructions.md)"
Write-Host "`nMechanical Guards active: Git Pre-Commit (TDD & Secret Shield)"
Write-Host "`nHappy hacking!" -ForegroundColor Yellow
