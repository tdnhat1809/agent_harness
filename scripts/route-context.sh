#!/usr/bin/env bash
# Dynamic Context Sharding & Task-Scoped Rule Selector (Bash Twin)
set -euo pipefail

PROMPT="${1:-}"
DOMAIN="${2:-auto}"
FORMAT="${3:-markdown}"

# 1. Classify Domain if auto
if [[ "$DOMAIN" == "auto" ]]; then
    p=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')
    if [[ "$p" =~ (ui|ux|frontend|css|html|react|tailwind|component|button|layout|color|styling) ]]; then
        DOMAIN="frontend-ui"
    elif [[ "$p" =~ (reverse|binary|decompile|ida|ghidra|exploit|pwn|apk|cve|malware|firmware|radare2) ]]; then
        DOMAIN="security-re"
    elif [[ "$p" =~ (docker|container|k8s|kubernetes|ci|cd|github\ action|workflow|devops|deploy|pipeline) ]]; then
        DOMAIN="devops-ci"
    elif [[ "$p" =~ (doc|docs|readme|document|refactor|clean\ code|comment) ]]; then
        DOMAIN="docs-refactor"
    elif [[ "$p" =~ (api|backend|database|sql|migration|fastapi|express|django|endpoint|server|postgres|mongo|sqlite|orm) ]]; then
        DOMAIN="backend-api"
    else
        DOMAIN="general-engineering"
    fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL_RULES=$(find "$SCRIPT_DIR/../.agents/rules" -name "*.md" 2>/dev/null | wc -l || echo "23")

case "$DOMAIN" in
    "frontend-ui")
        DESC="Frontend UI/UX Craft, SVG icon enforcement, WCAG contrast and layout preservation"
        RULES=".agents/rules/anti-ai-slop-ui.md .agents/rules/anti-regression-ui-preservation.md .agents/rules/ui-ux-craft.md"
        ROLES="react-build-resolver code-reviewer"
        SKILLS="web-design-guidelines impeccable-design design-taste vercel-react-best-practices"
        ;;
    "security-re")
        DESC="Binary reverse engineering, vulnerability analysis, and zero-hallucinated API recovery"
        RULES=".agents/rules/reverse-skill.md .agents/rules/autonomous-research.md"
        ROLES="security-reviewer spec-miner"
        SKILLS="reverse-engineering reverse-engineer-anything ida-reverse ghidra-reverse radare2 pwn-chain"
        ;;
    "backend-api")
        DESC="API design, transactional database migrations, strict TDD, and multi-goal convergence"
        RULES=".agents/rules/zero-drop-multi-goal.md .agents/rules/autonomous-research.md .agents/rules/clarify-before-mutate.md"
        ROLES="lead dev qa database-reviewer"
        SKILLS="test-driven-development database-migrations-design python-engineering go-engineering rust-engineering"
        ;;
    "devops-ci")
        DESC="Containerization, CI/CD pipelines, secret isolation, and immutable infrastructure"
        RULES=".agents/rules/git-safety-net.md .agents/rules/guardrails.md"
        ROLES="devops architect"
        SKILLS="docker-devops-ci cloud-k8s"
        ;;
    "docs-refactor")
        DESC="High-signal technical documentation, anti-overengineering, and clean typography"
        RULES=".agents/rules/ponytail.md .agents/rules/caveman.md"
        ROLES="code-reviewer"
        SKILLS="docs-generator engineering-wisdom"
        ;;
    *)
        DESC="Standard Red-Green-Refactor, empirical proof, and systematic root-cause isolation"
        RULES=".agents/rules/zero-drop-multi-goal.md .agents/rules/autonomous-research.md"
        ROLES="lead dev qa"
        SKILLS="test-driven-development systematic-debugging verification-before-completion"
        ;;
esac

CORE_RULES="docs/INVARIANTS.md .agents/rules/guardrails.md .agents/rules/human-identity-anti-slop.md .agents/rules/auto-experience-journaling.md .agents/rules/anti-loop-circuit-breaker.md"

if [[ "$FORMAT" == "summary" ]]; then
    echo "[CONTEXT SHARD: $DOMAIN] Loaded domain focus ($DESC)"
elif [[ "$FORMAT" == "json" ]]; then
    echo "{\"domain\":\"$DOMAIN\",\"description\":\"$DESC\",\"rules\":[\"$CORE_RULES $RULES\"],\"roles\":[\"$ROLES\"],\"skills\":[\"$SKILLS\"]}"
else
    echo "### Dynamic Context Shard: $DOMAIN"
    echo "> **Domain Focus**: $DESC"
    echo ""
    echo "#### Active Invariants & Rules"
    for r in $CORE_RULES $RULES; do
        echo "- \`$r\`"
    done
    echo ""
    echo "#### Recommended Subagent Roles"
    for ro in $ROLES; do
        echo "- \`@$ro\`"
    done
    echo ""
    echo "#### Loaded Domain Skills"
    for sk in $SKILLS; do
        echo "- \`$sk\`"
    done
fi
