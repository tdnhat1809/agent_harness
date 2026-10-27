# Claude Code Project Guidelines & Harness Entrypoint

<!-- HARNESS:BEGIN -->
## Core Harness & System of Record
This project operates under the **Agent Harness Architecture**.
Always treat repository files, tests, git history, and runtime diagnostics as the single source of truth.
Read `docs/WORKFLOW.md` before executing complex or multi-phase tasks.

## 5 Guardrails Mandates (Non-Negotiable)
1. **Nói chuyện với số liệu thực tế (Empirical Metrics Only)**:
   Base all diagnoses and claims on verifiable runtime evidence (exit codes, logs, compiler output, test pass rates).
2. **Viết test trước khi làm (Strict TDD / Red-Green-Refactor)**:
   Write a failing test (RED) before writing any implementation code (GREEN), then refactor.
3. **Tự động spawn subagent đối chiếu ngữ cảnh (Subagent Cross-Check)**:
   Maintain strict context separation and verify interfaces across boundaries independently.
4. **Vòng lặp liên tục tới khi đạt Goal (Continuous Convergence Loop)**:
   Execute the closed loop: Diagnose -> Test RED -> Implement GREEN -> Verify Proof -> Measure.
5. **Tự động đúc kết kinh nghiệm (Auto-Experience Journaling)**:
   Automatically append root cause and invariant lessons into `docs/memory/failure-journal.md` (via `scripts/record-lesson.ps1` or `.sh`) upon defect fixes or feature completion. Detail: `.agents/rules/auto-experience-journaling.md`.

## 👥 Autonomous Department Scaling
Automatically scale role activation based on prompt scope:
- **Tier 1 (Small / 1 file)**: Solo Dev (`@dev`) via fast TDD.
- **Tier 2 (Medium / 2-4 files)**: Trio Squad (`@lead` + `@dev` + `@qa`).
- **Tier 3 (Large / Auth / Payment / Multi-service / Migration)**: Full IT Department (`@lead` + `@dev` + `@qa` + `@security` + `@devops`) with 5-signoff verification.

## 🤖 Autonomous Stack & Test Discovery (Zero-Touch)
Do not ask the user for build or test instructions. Automatically discover them from repository files:
- **Node/TS**: `package.json` -> `pnpm test` / `npm test` / `bun test`
- **Python**: `pyproject.toml` / `pytest.ini` -> `pytest` / `uv run pytest`
- **Go**: `go.mod` -> `go test -v ./...`
- **Rust**: `Cargo.toml` -> `cargo test`
- **General**: `Makefile` / `Taskfile.yml`

## Safety Directives
- **Headless Mode Always**: All browser interactions (Playwright, Puppeteer) MUST run in headless mode (`headless: true`).
<!-- HARNESS:END -->
