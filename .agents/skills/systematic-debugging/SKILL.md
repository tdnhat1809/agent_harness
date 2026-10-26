---
name: systematic-debugging
description: Root-cause isolation, hypothesis testing, binary search, non-destructive diagnosis, and anti-guesswork debugging.
---

# Superpowers: Systematic Debugging

Stop guessing. Follow the scientific method to isolate and eliminate bugs.

## Debugging Protocol

### Step 1: Reproduce Reliably
- Create a minimal reproducible test case, script, or curl command.
- Capture the exact input, error message, stack trace, and environmental conditions.

### Step 2: Formulate Falsifiable Hypotheses
- State explicitly: *"If hypothesis X is true, then changing variable Y will result in outcome Z."*
- Rank hypotheses by likelihood and ease of verification.

### Step 3: Binary Search & Instrumentation
- Add targeted logging or assertions along the data pipeline.
- Bisect the execution flow: Is the data correct before step A? Is it corrupt at step B?
- Never apply random changes hoping the bug disappears.

### Step 4: Fix Root Cause & Validate
- Address the structural cause, not just the symptom.
- Add a regression test that fails before the fix and passes after.
- Verify that adjacent systems remain healthy and unaffected.
