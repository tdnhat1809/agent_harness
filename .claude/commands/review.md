---
description: Run multi-stage code review assessing correctness, invariants, security, and performance
argument-hint: [files or git diff to review]
---

# /review Command Execution

Review target: **$ARGUMENTS**

## Assessment Criteria:
1. **Correctness**: Does the logic accurately fulfill the contract and handle edge cases (nulls, empty lists, boundaries)?
2. **Architectural Invariants**: Does this violate repository patterns, domain boundaries, or introduce cyclic dependencies?
3. **Security**: Audit for OWASP Top 10, SQL/command injection, authentication bypass, secret exposure, or unsafe deserialization.
4. **Performance**: Check for N+1 database queries, unnecessary allocations, unbounded loops, or blocking calls in async contexts.
5. Provide actionable feedback with specific code snippets and line numbers.
