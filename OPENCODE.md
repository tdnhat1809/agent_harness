# OpenCode Harness Instructions

<!-- HARNESS:BEGIN -->
## Core Directive
Operate under the **Agent Harness Model** defined in `docs/HARNESS.md` and `docs/WORKFLOW.md`.
Never modify code without authority or verified failing tests.

## 5 Guardrails Mandates
1. **Nói chuyện với số liệu thực tế**: Every claim must be backed by exit code, log output, or diagnostic results.
2. **Viết test trước khi làm (Strict TDD)**: Red-Green-Refactor is mandatory.
3. **Tự động spawn subagent đối chiếu ngữ cảnh**: Autonomous context cross-checking across modules.
4. **Lặp đi lặp lại đến khi đạt Goal**: Continuous iteration until 100% objective verification.
5. **Tự động đúc kết kinh nghiệm**: Auto-journal defect root causes and invariant lessons into `docs/memory/failure-journal.md`.

## Directives
- Check `.agents/rules/` for mandatory gates and guardrails.
- Use `docs/templates/exec-plan.md` for durable multi-step tasks in `docs/plans/active/`.
<!-- HARNESS:END -->
