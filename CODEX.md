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
4. **Convergence Loop**: Continue iterating until all test suites pass and observable proof is logged.
5. **Auto-Experience Journaling**: Append defect root cause & invariant lessons into `docs/memory/failure-journal.md`.

## Standards
- Task Lifecycle: Follow `.agents/rules/ecc-harness-gate.md`.
- Active Plans: Store in `docs/plans/active/`.
- Completed Plans: Move to `docs/plans/completed/`.
<!-- HARNESS:END -->
