---
name: subagent-driven-development
description: Fast 2-5 minute task delegation, context isolation, verifiable task contracts, and deterministic subagent handoffs.
---

# Superpowers: Subagent-Driven Development

Decompose large tasks into tightly-bounded, independent sub-units executed in parallel or sequentially with strict context isolation.

## Principles

1. **Context Economy**:
   - Keep parent agent context clean.
   - Pass only required file paths, contracts, and acceptance criteria to the subagent.

2. **Strict Acceptance Criteria**:
   - Every subagent task must define:
     - Exact input files
     - Exact modifications or output format
     - Execution & validation command that exits with code 0

3. **Verifiable Result Handoff**:
   - Subagent returns structured summary:
     - Files changed
     - Proof of test execution
     - Any residual risks or follow-up items
