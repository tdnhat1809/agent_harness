---
name: writing-plans
description: Spec-first implementation planning, bite-sized tasks, dependency mapping, and observable verification criteria.
---

# Superpowers: Spec-First Implementation Planning

Never write production code without an explicit, verifiable plan.

## Structure of a Production Implementation Plan

1. **Context & Goals**:
   - What problem is being solved?
   - What are the invariants that must remain unbroken?

2. **Architecture & Scope Boundaries**:
   - Files to create (`[NEW]`), modify (`[MODIFY]`), or remove (`[DELETE]`).
   - Contracts, APIs, DB schemas, or state changes involved.

3. **Bite-Sized Task Breakdown (2–5 Minutes Per Task)**:
   - Each task must have a single objective.
   - Tasks must specify input, output, and immediate validation command.

4. **Verification Strategy**:
   - Automated tests (Red -> Green).
   - Observable runtime proofs (logs, HTTP responses, screenshots).

5. **Risk & Rollback Plan**:
   - Failure modes and quick recovery actions.
