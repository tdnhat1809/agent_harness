---
name: workflow-plan
description: Global /plan workflow for analyzing requirements, mapping dependencies, and generating structured technical execution plans.
---

# Global Workflow: /plan

Execute this structured planning workflow when initiated by `/plan` or when starting any substantial feature or architectural change.

## Workflow Phases

### Phase 1: Context & Invariant Ingestion
- Read active requirements, existing data schemas, and domain interfaces.
- Identify core business invariants and system boundaries.

### Phase 2: Specification & Boundary Definition
- Draft clear user stories, API contracts, database schema migrations, and UI mockups.
- Define what is in-scope vs. out-of-scope.

### Phase 3: Task Breakdown & Risk Matrix
- Break implementation into atomic 2–5 minute tasks.
- Identify risk areas (breaking changes, external API rate limits, schema locks).

### Phase 4: Verification Definition
- Define exact test commands and observable criteria for each step.
- Present implementation plan to user and request approval.
