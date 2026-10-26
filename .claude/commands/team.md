---
description: Simulate a virtual IT department (Tech Lead, Senior Dev, QA Tester, AppSec) for cross-checking and zero-defect delivery
argument-hint: [task description]
---

# /team Command Execution (Virtual IT Department Swarm)

Execute task: **$ARGUMENTS** through the **Virtual IT Department Cross-Checking Protocol**.

## Execution Flow:
1. **🏛️ Tech Lead (`@lead`)**:
   - Evaluate requirements and architectural invariants.
   - Decompose task and approve implementation scope.
2. **💻 Senior Developer (`@dev`)**:
   - Write failing test first (RED).
   - Write minimal implementation (GREEN) and refactor.
3. **🧪 QA Tester (`@qa`)**:
   - Perform adversarial edge-case testing (nulls, boundary limits, race conditions).
   - Confirm zero regression on the existing test suite.
4. **🛡️ AppSec Specialist (`@security`)**:
   - Check OWASP Top 10 vulnerabilities, input sanitization, and secret leaks.
5. **🚀 DevOps Engineer (`@devops`)**:
   - Confirm clean build exit code 0 and format semantic Git commit.

Present the final output formatted with individual department sign-offs!
