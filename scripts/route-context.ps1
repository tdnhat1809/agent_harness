<#
.SYNOPSIS
    Dynamic Context Sharding & Task-Scoped Rule Selector.
.DESCRIPTION
    Analyzes user prompt or explicit domain to select only high-priority rules, roles, 
    and skills, eliminating context dilution and saving tokens.
.PARAMETER Prompt
    The user request prompt to analyze.
.PARAMETER Domain
    Optional explicit domain override (frontend-ui, backend-api, security-re, devops-ci, docs-refactor).
.PARAMETER Format
    Output format: 'markdown' (default), 'json', or 'summary'.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Prompt = "",

    [Parameter(Position = 1)]
    [ValidateSet("auto", "frontend-ui", "backend-api", "security-re", "devops-ci", "docs-refactor", "general-engineering")]
    [string]$Domain = "auto",

    [Parameter()]
    [ValidateSet("markdown", "json", "summary")]
    [string]$Format = "markdown"
)

$ErrorActionPreference = "Stop"

# 1. Classify Domain if auto
if ($Domain -eq "auto") {
    $p = $Prompt.ToLower()
    if ($p -match '(\bui\b|\bux\b|frontend|css|html|react|tailwind|component|button|layout|color|giao diện|giao dien|styling|dashboard|theme)') {
        $Domain = "frontend-ui"
    }
    elseif ($p -match '(reverse|binary|decompile|ida|ghidra|exploit|pwn|apk|cve|malware|firmware|dịch ngược|dich nguoc|bảo mật|bao mat|radare2)') {
        $Domain = "security-re"
    }
    elseif ($p -match '(docker|container|k8s|kubernetes|\bci\b|\bcd\b|github action|workflow|devops|deploy|pipeline)') {
        $Domain = "devops-ci"
    }
    elseif ($p -match '(\bdoc\b|docs|readme|document|tài liệu|tai lieu|refactor|clean code|comment)') {
        $Domain = "docs-refactor"
    }
    elseif ($p -match '(\bapi\b|backend|database|sql|migration|fastapi|express|django|endpoint|server|postgres|mongo|sqlite|orm)') {
        $Domain = "backend-api"
    }
    else {
        $Domain = "general-engineering"
    }
}

# 2. Universal Core Invariants (Always Loaded)
$coreRules = @(
    "docs/INVARIANTS.md",
    ".agents/rules/guardrails.md",
    ".agents/rules/human-identity-anti-slop.md",
    ".agents/rules/auto-experience-journaling.md",
    ".agents/rules/anti-loop-circuit-breaker.md"
)

# 3. Domain Sharding Map
$domainConfig = @{
    "frontend-ui" = @{
        "rules" = @(".agents/rules/anti-ai-slop-ui.md", ".agents/rules/anti-regression-ui-preservation.md", ".agents/rules/ui-ux-craft.md");
        "roles" = @("react-build-resolver", "code-reviewer");
        "skills" = @("web-design-guidelines", "impeccable-design", "design-taste", "vercel-react-best-practices");
        "description" = "Frontend UI/UX Craft, SVG icon enforcement, WCAG contrast and layout preservation"
    };
    "security-re" = @{
        "rules" = @(".agents/rules/reverse-skill.md", ".agents/rules/autonomous-research.md");
        "roles" = @("security-reviewer", "spec-miner");
        "skills" = @("reverse-engineering", "reverse-engineer-anything", "ida-reverse", "ghidra-reverse", "radare2", "pwn-chain");
        "description" = "Binary reverse engineering, vulnerability analysis, and zero-hallucinated API recovery"
    };
    "backend-api" = @{
        "rules" = @(".agents/rules/zero-drop-multi-goal.md", ".agents/rules/autonomous-research.md", ".agents/rules/clarify-before-mutate.md");
        "roles" = @("lead", "dev", "qa", "database-reviewer");
        "skills" = @("test-driven-development", "database-migrations-design", "python-engineering", "go-engineering", "rust-engineering");
        "description" = "API design, transactional database migrations, strict TDD, and multi-goal convergence"
    };
    "devops-ci" = @{
        "rules" = @(".agents/rules/git-safety-net.md", ".agents/rules/guardrails.md");
        "roles" = @("devops", "architect");
        "skills" = @("docker-devops-ci", "cloud-k8s");
        "description" = "Containerization, CI/CD pipelines, secret isolation, and immutable infrastructure"
    };
    "docs-refactor" = @{
        "rules" = @(".agents/rules/ponytail.md", ".agents/rules/caveman.md");
        "roles" = @("code-reviewer");
        "skills" = @("docs-generator", "engineering-wisdom");
        "description" = "High-signal technical documentation, anti-overengineering, and clean typography"
    };
    "general-engineering" = @{
        "rules" = @(".agents/rules/zero-drop-multi-goal.md", ".agents/rules/autonomous-research.md");
        "roles" = @("lead", "dev", "qa");
        "skills" = @("test-driven-development", "systematic-debugging", "verification-before-completion");
        "description" = "Standard Red-Green-Refactor, empirical proof, and systematic root-cause isolation"
    }
}

$selected = $domainConfig[$Domain]
$allSelectedRules = $coreRules + $selected["rules"]
$totalRepoRules = (Get-ChildItem -Path "$PSScriptRoot\..\.agents\rules\*.md" -ErrorAction SilentlyContinue).Count
if ($totalRepoRules -eq 0) { $totalRepoRules = 23 }

$unloadedRules = $totalRepoRules - $selected["rules"].Count
$savedTokenPct = [math]::Round(($unloadedRules / $totalRepoRules) * 100)

# 4. Output Formatting
if ($Format -eq "json") {
    $out = [PSCustomObject]@{
        domain = $Domain
        description = $selected["description"]
        rules = $allSelectedRules
        roles = $selected["roles"]
        skills = $selected["skills"]
        stats = [PSCustomObject]@{
            total_rules = $totalRepoRules
            selected_rules = $allSelectedRules.Count
            token_savings_pct = "$($savedTokenPct)%"
        }
    }
    $out | ConvertTo-Json -Depth 4
}
elseif ($Format -eq "summary") {
    Write-Host "[CONTEXT SHARD: $Domain] Rules: $($allSelectedRules.Count)/$($totalRepoRules) (Saved ~$($savedTokenPct)% token noise)" -ForegroundColor Cyan
}
else {
    Write-Output "### Dynamic Context Shard: $Domain"
    Write-Output "> **Domain Focus**: $($selected['description'])"
    Write-Output "> **Token Optimization**: Sharded $($selected['rules'].Count) domain rules out of $totalRepoRules total. **~$($savedTokenPct)% context noise eliminated.**"
    Write-Output ""
    Write-Output "#### Active Invariants & Rules"
    foreach ($r in $allSelectedRules) {
        Write-Output ('- `{0}`' -f $r)
    }
    Write-Output ""
    Write-Output "#### Recommended Subagent Roles"
    foreach ($ro in $selected["roles"]) {
        Write-Output ('- `@{0}`' -f $ro)
    }
    Write-Output ""
    Write-Output "#### Loaded Domain Skills"
    foreach ($sk in $selected["skills"]) {
        Write-Output ('- `{0}`' -f $sk)
    }
}
