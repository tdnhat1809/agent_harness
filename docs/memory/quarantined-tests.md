# Quarantined Flaky Tests Register

This register tracks non-deterministic tests quarantined to protect agents from regression loops.

| Quarantined Date | Test Command | Flake Rate | Iterations | Status | Action Required |
|---|---|---|---|---|---|
| 2026-10-29 15:52:54 | powershell -Command '$v = (Get-Random -Minimum 1 -Maximum 10); if ($v -gt 5) { exit 0 } else { exit 1 }' | 60% | 5 | QUARANTINED | Isolate shared state / mock timer |
