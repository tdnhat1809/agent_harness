# ⚡ ANTI-LOOP CIRCUIT BREAKER & SYSTEMATIC RECOVERY PROTOCOL

## §1. THE 3-STRIKE CIRCUIT BREAKER
When an automated task, test run, or compilation error fails 3 consecutive times with the exact same failure signature:
1. **IMMEDIATE HALT**: The agent MUST STOP calling terminal commands, browser actions, or editing tools in a loop.
2. **NO BRUTE-FORCE MUTATIONS**: Do NOT attempt random code modifications or "guess-and-check" fixes.
3. **DIAGNOSTIC REPORT**: Output a structured `[CIRCUIT BREAKER TRIGGERED]` notice to the user:
   - **Observed Symptom**: Exact error message, exit code, and line number.
   - **Failed Hypotheses (Tripped Strikes)**: What was tried in Attempt 1, 2, and 3, and why each failed.
   - **Root Cause Isolation**: Result of binary search or trace analysis.
   - **Proposed Options**: 2-3 concrete paths forward (e.g., architectural change, dependency update, manual intervention required).
   - **Actionable Decision**: Ask the user to select or authorize the next path.
4. **PERSIST FAILURE SIGNATURE**: Run `scripts/record-lesson.ps1` (or `record-lesson.sh`) to log the failure signature and failed hypotheses into `docs/memory/failure-journal.md` before halting. Never allow 3 failed attempts to vanish without permanent failure journal persistence.

## §2. ANTI-SPIN / TOKEN CONSERVATION MANDATE
- Never loop more than 3 times on the same failing command.
- Never poll a background task in a tight loop. Always use reactive wakeup or structured timers.
- If a build fails repeatedly due to an external environment issue (missing SDK, wrong system arch, network block), flag immediately as an external infrastructure blocker rather than modifying business logic.
