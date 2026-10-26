---
name: codex-rescue
description: Codex deep review & rescue skill. Use when complex debugging deadlocks occur, subtle race conditions emerge, or when an independent second opinion is requested.
---

# Codex Plugin: Deep Review & Emergency Rescue

Use this skill when stuck in complex architectural deadlocks, subtle concurrency bugs, or deep refactoring challenges.

## Rescue Protocol

1. **Independent AST & Data Flow Audit**:
   - Re-trace data flow from absolute entry point to the point of failure.
   - Ignore all previous unverified assumptions.

2. **Root Cause Dissection**:
   - Identify whether the defect stems from:
     - Asynchronous race conditions / missing mutex locks.
     - Event loop blocking / unhandled promise rejections.
     - Type-casting illusions (`as any`, unchecked JSON parses).
     - State synchronization lag across distributed microservices.

3. **Minimal Surgical Resolution**:
   - Propose the cleanest, most resilient fix with 0 collateral damage.
   - Add invariant assertion tests to permanently safeguard the fix.
