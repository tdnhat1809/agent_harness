---
name: workflow-quality-gate
description: Global /quality-gate workflow validating test passes, build status, invariant enforcement, and zero regressions before deployment or merge.
---

# Global Workflow: /quality-gate

Pre-merge and pre-deploy automated validation checklist.

## Gate Criteria (Must ALL pass 100%)

1. **Type & Compilation Gate**:
   - `pnpm --filter <pkg> build` exits 0 with 0 errors.

2. **Automated Test Gate**:
   - All unit tests and integration tests pass without flakiness.

3. **Runtime Service Gate**:
   - Relevant microservices and apps launch cleanly without unhandled rejections or crash loops.

4. **Security & Boundary Gate**:
   - No exposed secret keys or `.env` credential leaks.
   - Authentication and authorization checks verified.

5. **Performance & Bundle Gate**:
   - Bundle sizes within acceptable budgets; dynamic imports used where appropriate.
