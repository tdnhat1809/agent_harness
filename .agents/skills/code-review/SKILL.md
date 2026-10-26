---
name: code-review
description: Comprehensive multi-stage code review assessing behavioral correctness, architectural invariants, security, and performance.
---

# Superpowers: Code Review & Quality Assurance

## Review Dimensions

1. **Behavioral Correctness**:
   - Does the implementation fully solve the requested user need?
   - Are edge cases (null, empty, concurrent, timeout) handled gracefully?

2. **Architectural Invariants & Modularity**:
   - Are domain boundaries respected?
   - Is logic separated cleanly into services, controllers, and UI components?
   - No unnecessary dependencies or leaky abstractions.

3. **Performance & Resource Consumption**:
   - No N+1 queries, async waterfalls, or unnecessary client-side re-renders.
   - Heavy assets lazy-loaded; database indexes present on queried columns.

4. **Security & Input Validation**:
   - All inputs validated and sanitized at boundaries.
   - No authentication/authorization bypasses.
   - No sensitive credentials in client-side code.
