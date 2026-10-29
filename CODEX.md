# Codex Agent Instructions

<!-- HARNESS:BEGIN -->
## Core Directive
You are working within an **Agent Harness** repository.
The repository truth wins: always inspect active code, tests, and documentation before modifying.
Read `docs/WORKFLOW.md` for task shapes and execution requirements.

## 5 Guardrails Mandates
1. **Empirical Evidence Only**: Prove assertions with executable evidence (command output, logs, exit codes).
2. **Strict TDD**: Write a failing test first before editing implementation code.
3. **Subagent & Context Separation**: Cross-verify service boundaries independently.
4. **Convergence Loop & Zero-Drop**: Iterate until all targets pass; extract Goal Matrix for multi-issue prompts and ban premature signoff without full-suite proof.
5. **Auto-Experience Journaling**: Append defect root cause & invariant lessons into `docs/memory/failure-journal.md`.

## Standards
- Task Lifecycle: Follow `.agents/rules/ecc-harness-gate.md`.
- Active Plans: Store in `docs/plans/active/`.
- UI Quality: Banned emojis as icons; use Lucide/Heroicons SVG (`anti-ai-slop-ui.md`).
- Research Mandate: Research unfamiliar APIs via `gh` CLI/web before coding (`autonomous-research.md`).
- Completed Plans: Move to `docs/plans/completed/`.
<!-- HARNESS:END -->
