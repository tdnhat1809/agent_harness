# Execution Plan: flaky-debate-telemetry-timemachine

Date: 2026-10-29

## Status

Completed

## Outcome

Triển khai thành công 4 hệ thống vận hành tự trị nâng cao cho bộ khung Agent Harness:
1. Flaky Test Isolator (`scripts/flaky-detector.ps1` & `.sh`): Phát hiện và cách ly test chập chờn, tính tỷ lệ flake rate, ghi nhận vào `docs/memory/quarantined-tests.md`.
2. Multi-Agent Adversarial Debate Protocol (`scripts/agent-debate.ps1` & `.sh`): Triệt tiêu thiên kiến xác nhận bằng quy trình tranh biện đối kháng 3 vai trò (`@dev`, `@security`/`@qa`, `@lead`), xuất biên bản ra `docs/reviews/`.
3. Live Token Telemetry & ROI Profiler (`scripts/token-telemetry.ps1` & `.sh`): Giám sát token, tính chi phí đa mô hình (Claude 3.7 Sonnet, GPT-4o, Gemini 2.5 Pro), đo chỉ số hội tụ (Convergence Score), và cảnh báo ngân sách.
4. Micro-Checkpoint Time Machine (`scripts/time-machine.ps1` & `.sh`): Tua ngược trạng thái code theo từng bước vi mô nhưng bảo tồn nguyên vẹn `docs/memory/` và `docs/plans/`.

## Context

- `docs/INVARIANTS.md`: 10 Invariants cốt lõi.
- `scripts/`: Hệ sinh thái công cụ hiện tại mở rộng lên 20 công cụ.

## Scope

In scope:
- `scripts/flaky-detector.ps1` & `.sh`
- `scripts/agent-debate.ps1` & `.sh`
- `scripts/token-telemetry.ps1` & `.sh`
- `scripts/time-machine.ps1` & `.sh`
- Cập nhật `doctor.ps1`, `doctor.sh`, `.gitignore`, và `README.md`.

Out of scope:
- Phương án 3 (Dependency CVE Shield) đã được hoãn lại theo yêu cầu người dùng.

## Multi-Goal Decomposition Matrix (Zero-Drop)

- [x] Target 1: Flaky Test Isolator & Bisection Engine (`scripts/flaky-detector.ps1` & `flaky-detector.sh`)
- [x] Target 2: Multi-Agent Adversarial Debate Protocol (`scripts/agent-debate.ps1` & `agent-debate.sh`)
- [x] Target 3: Live Token Telemetry & ROI Profiler (`scripts/token-telemetry.ps1` & `token-telemetry.sh`)
- [x] Target 4: Micro-Checkpoint Time Machine (`scripts/time-machine.ps1` & `time-machine.sh`)
- [x] Target 5: Full Verification, Documentation & Production Sign-off (`doctor.ps1`, `eval-harness.ps1`, `README.md`)

## Progress

- [x] Task 1: Triển khai Target 1 - Flaky Test Isolator (Verified)
- [x] Task 2: Triển khai Target 2 - Multi-Agent Adversarial Debate Protocol (Verified)
- [x] Task 3: Triển khai Target 3 - Live Token Telemetry & ROI Profiler (Verified)
- [x] Task 4: Triển khai Target 4 - Micro-Checkpoint Time Machine (Verified)
- [x] Task 5: Thẩm định toàn diện, cập nhật docs và commit (Verified)

## Validation

- `scripts/flaky-detector.ps1`: Verified deterministic pass (100%), deterministic fail (100%), and non-deterministic flake (60% quarantine).
- `scripts/agent-debate.ps1`: Generated structured debate record in `docs/reviews/` with 3 phases and Arbiter verdict.
- `scripts/token-telemetry.ps1`: Verified token extraction, multi-model pricing calculation, and budget guardrail.
- `scripts/time-machine.ps1`: Verified snapshot capture (658 files), checkpoint listing, state rollback, and snapshot purging while preserving `docs/memory/` and `docs/plans/`.
- `scripts/doctor.ps1`: All 6 sections passed, 14 operational tools registered.
- `scripts/eval-harness.ps1`: 100/100 points, Grade A+.
- `scripts/test-agent-adherence.ps1`: 100/100 points, Grade A+.
- Zero-Emoji scan on `README.md`: Clean.

## Result

Tất cả 4 mục tiêu nâng cấp đã được triển khai đầy đủ cả bản PowerShell và Bash, tích hợp vào hệ thống, và đạt chứng nhận 100/100 điểm.
