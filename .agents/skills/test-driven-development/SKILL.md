---
name: test-driven-development
description: Strict Red-Green-Refactor test-driven development workflow. Write failing unit/integration tests before implementing code.
---

# Superpowers: Test-Driven Development (TDD)

## The Iron Law of TDD

> **No production code shall be written unless to make a failing automated test pass.**

## Cycle: RED -> GREEN -> REFACTOR

### 1. RED Phase (Failing Test)
- Write a minimal test specifying the desired behavior or edge case.
- Run the test suite and confirm it **fails for the expected reason** (not due to syntax or import error).

### 2. GREEN Phase (Make it Pass)
- Write the minimal amount of production code needed to satisfy the test.
- Run the test suite and confirm it **passes**.

### 3. REFACTOR Phase (Clean & Invariant Check)
- Eliminate duplication, improve naming, optimize hot paths.
- Ensure all tests continue to pass with 0 regressions.
- Verify typing, linting, and formatting.

## Edge Case Checklist
- Empty / null / undefined inputs
- Boundary limits (0, 1, max, negative)
- Network timeouts, disconnects, and async race conditions
- Concurrent access / idempotency keys
