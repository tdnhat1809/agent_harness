---
name: ecc-refactoring
description: ECC safe refactoring workflow. Preserves behavioral contracts, extracts reusable abstractions, and eliminates technical debt.
---

# ECC: Safe Refactoring

## Refactoring Guidelines

1. **Behavioral Invariance**:
   - Refactoring must NOT alter externally observable system behavior.
   - Run tests before starting refactoring and after every incremental change.

2. **Stepwise Incremental Steps**:
   - Step 1: Add or verify comprehensive test coverage around target code.
   - Step 2: Extract small functions / classes / modules without changing caller interfaces.
   - Step 3: Swap implementation details while keeping tests green.
   - Step 4: Deprecate or remove dead legacy code paths.
