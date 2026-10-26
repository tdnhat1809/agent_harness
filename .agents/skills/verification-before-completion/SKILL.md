---
name: verification-before-completion
description: Executable proof requirement, zero unverified assumptions, runtime validation, anti-hollow testing, and empirical evidence before claiming task completion.
---

# Superpowers: Verification Before Completion

**Rule: Never claim completion without fresh executable evidence and real empirical data.**

Before declaring any task complete, you MUST execute and provide real terminal evidence for all 4 gates below. Adhere strictly to the directives in `skills/empirical-evidence-guard`.

## Mandatory Verification Gates

### 1. Static Health & Zero-Error Compilation
- **Typecheck passed**: `tsc --noEmit`, `mypy`, `cargo check`, or `go build ./...` must exit with code 0.
- **Lint check passed**: 0 critical errors or unformatted files (`ruff`, `eslint`, `golangci-lint`, `clippy`).

### 2. Automated Behavior & Test Thật (Anti-Hollow TDD)
- **Relevant unit & integration tests pass**: Capture terminal stdout/stderr proving all tests pass.
- **No hollow assertions**: Ban `expect(true).toBe(true)` or pure mock-testing.
- **Edge-case proof**: Must include tests for null, empty inputs, boundaries, and expected error states.
- **New coverage added**: Every newly implemented branch must have executable proof.

### 3. Tool-Driven Audit Thật (Real Security & SCA)
- **Dependency Vulnerability Scan**: Run native audit (`npm audit`, `pip-audit`, `cargo audit`, `govulncheck`).
- **Secret Scan**: Verify 0 private keys, `.env` files, or credentials staged in Git.

### 4. Runtime & Observable Evidence
- **If UI**: Rendered in browser/preview, responsive on mobile & desktop, zero console errors.
- **If API / Service**: Endpoint returns expected HTTP status, schema, and payload.
- **If Daemon / Worker**: Process healthy in PM2 / Docker, logs clean without crashes.
