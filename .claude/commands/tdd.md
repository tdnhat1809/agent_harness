---
description: Execute strict Test-Driven Development (Red-Green-Refactor)
argument-hint: [feature or function to implement]
---

# /tdd Command Execution

You are implementing: **$ARGUMENTS** under strict TDD.

## Mandatory Sequence:
1. **RED**: Write an automated unit or integration test describing the desired behavior.
2. Run the test command and **prove that it FAILS** with the expected error. Record the failure output.
3. **GREEN**: Write the minimal necessary implementation code to satisfy the test.
4. Run the test command again and **prove that it PASSES** (exit code 0).
5. **REFACTOR**: Clean up, optimize performance, and remove duplication while ensuring all tests remain green.
