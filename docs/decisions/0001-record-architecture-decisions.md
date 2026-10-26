# 1. Record Architecture Decisions (ADR)

Date: 2026-09-04
Status: Accepted

## Context
As software systems evolve, complex architectural choices are made across different development sessions and contributors. Without a durable record, agents and human developers waste tokens and time re-litigating previously resolved technical choices or inadvertently reversing sound decisions.

## Decision
We adopt Architecture Decision Records (ADRs) stored in `docs/decisions/` following the template in `docs/templates/decision.md`.

Each ADR will document:
1. Context and problem statement.
2. Considered options and technical tradeoffs.
3. Decision outcome and justification.
4. Positive and negative consequences.

## Consequences
- **Positive**: All future agent sessions will inspect `docs/decisions/` before suggesting major architectural changes.
- **Positive**: Architectural invariants remain persistent across long-running development loops.
- **Tradeoff**: Requires creating a short document when a new significant technical choice is made.
