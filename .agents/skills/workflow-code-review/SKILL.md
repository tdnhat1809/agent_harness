---
name: workflow-code-review
description: Global /code-review workflow for automated static analysis, architecture validation, security audit, and quality assessment.
---

# Global Workflow: /code-review

Comprehensive automated and manual code review pipeline.

## Review Stages

1. **Static Analysis & Type Consistency**:
   - Check TypeScript strict typing: no improper `any` or ignored lint warnings.
   - Verify contract synchronization across frontend, BFF, and microservices.

2. **Security & Data Sanitization**:
   - Verify proper authentication and tenant isolation (`tenantId` enforcement).
   - Check for SQL injection, command injection, path traversal, and sensitive log leakage.

3. **Performance & Scalability**:
   - Ensure database queries use proper indexes; avoid N+1 queries.
   - Verify React components avoid heavy unnecessary re-renders; use dynamic imports for large modules.

4. **Maintainability & Invariants**:
   - Code adheres to repository naming conventions, modularity, and error handling patterns.
   - Clean git diff with 0 commented-out dead code or leftover console logs.
