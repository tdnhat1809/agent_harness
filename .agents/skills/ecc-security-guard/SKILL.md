---
name: ecc-security-guard
description: ECC security guardrails. Enforces OWASP Top 10 defenses, tenant isolation, input sanitation, and secret protection.
---

# ECC: Security & Guardrails

## Security Checklist

1. **Multi-Tenant Isolation**:
   - Every database query and business action MUST verify tenant context (`tenantId`).
   - Cross-tenant data leakage is a critical vulnerability.

2. **Input Validation & Injection Prevention**:
   - Strict Zod / class-validator validation on all incoming DTOs.
   - Parameterized queries / ORM bindings for all database operations.
   - Safe path resolution (`path.basename`, avoiding `../` traversal).

3. **Authentication & Authorization**:
   - Enforce RBAC roles (`ADMIN`, `USER`, `VIEWER`) on every route.
   - Never trust client-provided IDs without verifying ownership against session token.
