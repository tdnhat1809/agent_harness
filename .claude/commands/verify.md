---
description: Run verification before completion gate to prove zero regressions and test pass
argument-hint: [optional scope]
---

# /verify Command Execution

Verify repository readiness and task completion.

## Mandatory Proof Requirements:
1. Run static type checking / compilation (e.g., `tsc --noEmit`, `mypy`, `cargo check`, `go build ./...`). Verify exit code 0.
2. Run automated test suites (unit + integration). Verify all tests pass with 0 failures.
3. Capture and display the exact terminal execution log as empirical evidence.
4. If a plan file exists in `docs/plans/active/`, update its verification checklist and prepare to move it to `docs/plans/completed/`.
