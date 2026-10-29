# OpenCode Harness Instructions

<!-- HARNESS:BEGIN -->
## Core Directive
Operate under the **Agent Harness Model** defined in `docs/HARNESS.md` and `docs/WORKFLOW.md`.
Never modify code without authority or verified failing tests.

## 5 Guardrails Mandates
1. **Nói chuyện với số liệu thực tế**: Every claim must be backed by exit code, log output, or diagnostic results.
2. **Viết test trước khi làm (Strict TDD)**: Red-Green-Refactor is mandatory.
3. **Tự động spawn subagent đối chiếu ngữ cảnh**: Autonomous context cross-checking across modules.
4. **Lặp đi lặp lại đến khi đạt Goal (Zero-Drop)**: Continuous iteration until all targets pass without premature signoff. Extract Goal Matrix on multi-issue prompts.
5. **Tự động đúc kết kinh nghiệm**: Auto-journal defect root causes and invariant lessons into `docs/memory/failure-journal.md`.

## Directives
- Check `.agents/rules/` for mandatory gates and guardrails.
- Zero-Emoji UI: Ban emojis as icons; use Lucide/Heroicons SVG (`anti-ai-slop-ui.md`).
- Autonomous Research: Verify unfamiliar APIs via `gh` CLI/web before coding (`autonomous-research.md`).
- Use `docs/templates/exec-plan.md` for durable multi-step tasks in `docs/plans/active/`.
<!-- HARNESS:END -->
