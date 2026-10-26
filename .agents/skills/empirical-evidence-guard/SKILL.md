---
name: empirical-evidence-guard
description: Enforces ground-truth empirical metrics, prevents hallucinated terminal logs, bans hollow/tautological tests, and mandates real tool-driven security audits.
triggers:
  - "dữ liệu thật"
  - "số liệu thật"
  - "test thật"
  - "audit thật"
  - "empirical metrics"
  - "anti-hallucination"
  - "real data"
  - "verify proof"
---

# Empirical Evidence Guard (Chống Số Liệu Giả, Test Ảo, Audit Bằng Mồm)

This skill enforces strict adherence to **Ground Truth**. AI agents are prone to hallucinating command outputs, writing hollow tests (`expect(true).toBe(true)`), over-mocking, or making superficial security claims without running real scanners.

This skill eliminates those anti-patterns with 3 mandatory protocols:

---

## 1. Giao thức Số Liệu Thật (Empirical Metrics & Anti-Fabrication Protocol)

### ❌ Những hành vi bị nghiêm cấm tuyệt đối:
- **Cấm bịa log terminal**: Tuyệt đối không tự gõ tay các dòng chữ giả dạng output terminal như `Tests: 12 passed, 0 failed` nếu chưa thực sự gọi tool chạy lệnh trong phiên làm việc.
- **Cấm tuyên bố hiệu năng cảm tính**: Không được nói "code chạy nhanh hơn nhiều", "tiết kiệm 50% RAM" nếu không có số liệu đo lường benchmark/profiler trước và sau (CPU ms, Memory MB, Query time).
- **Cấm suy đoán trạng thái**: Không được đoán "dịch vụ chắc chắn đã chạy" nếu chưa kiểm tra status code HTTP hoặc process status.

###  Quy chuẩn số liệu thật bắt buộc:
1. **Nguồn gốc rõ ràng (Traceability)**: Mọi con số (thời gian chạy ms, dung lượng RAM, tỷ lệ pass %, số test cases) đều phải trích xuất trực tiếp từ stdout/stderr của lệnh chạy thật trong terminal.
2. **Khả năng tái lập (Reproducibility)**: Đi kèm mỗi kết luận phải có câu lệnh CLI chính xác để người dùng có thể copy và chạy lại kiểm chứng độc lập.

---

## 2. Giao thức Test Thật (Anti-Hollow & Anti-Over-Mocking Testing Protocol)

### ❌ Những kiểu test bị cấm:
- **Tautological Tests (Test sáo rỗng)**:
  ```typescript
  // CẤM: Test không chứng minh được gì về logic nghiệp vụ
  expect(result).toBeDefined();
  expect(true).toBe(true);
  ```
- **Over-Mocking (Mock mù quáng)**:
  Mock luôn cả hàm đang cần kiểm thử, hoặc mock database/service đến mức test chỉ đang kiểm tra hành vi của chính... thư viện mock.
- **Test một chiều (Chỉ test Happy-path)**:
  Chỉ truyền dữ liệu đẹp, hoàn hảo; không test trường hợp dữ liệu lỗi, null, rỗng, số âm, timeout.

###  Tiêu chuẩn Test thật bắt buộc:
1. **Chứng minh 2 pha (Red-Green Verification)**:
   - **Pha RED**: Phải chạy test và chụp lại bằng chứng terminal báo FAIL (exit code != 0), và lỗi fail phải **đúng là do thiếu logic** (chứ không phải do lỗi cú pháp hoặc sai đường dẫn import).
   - **Pha GREEN**: Sau khi viết code, chạy lại test và chứng minh PASS (exit code == 0).
2. **Kiểm thử biên & Giá trị nghịch (Negative Testing)**:
   - Phải có ít nhất 2 bài test cho các trường hợp: Input `null` / `undefined`, chuỗi rỗng `""`, mảng rỗng `[]`, ID không tồn tại, số lượng vượt ngưỡng.
3. **Assert sâu (Deep Assertion)**:
   - Assert chính xác giá trị các trường quan trọng (`status`, `id`, `balance`, `errorCode`), kiểm tra sự thay đổi trạng thái database thật hoặc mock ở tầng I/O ngoài cùng.

---

## 3. Giao thức Audit Thật (Tool-Driven Security & Code Audit Protocol)

### ❌ Những kiểu audit bị cấm:
- **Audit bằng mắt (Visual-only audit)**: Đọc lướt qua code rồi tự nhận xét "Tôi thấy code rất an toàn, không có lỗ hổng bảo mật nào".
- **Bỏ qua thư viện phụ thuộc (Ignored dependencies)**: Chỉ audit code tự viết mà không quét CVE của các package bên thứ ba vừa cài đặt.

###  Tiêu chuẩn Audit thật bắt buộc:
Phải kích hoạt các công cụ phân tích tĩnh (SAST), quét lỗ hổng (SCA) và linter thực tế của từng ngôn ngữ:

| Ngăn xếp (Stack) | Lệnh Audit Thư viện (SCA) | Lệnh Quét Code & Linter (SAST) | Quét Rò rỉ Bí mật (Secret Scan) |
|---|---|---|---|
| **Node.js / TS** | `npm audit` hoặc `pnpm audit` | `npx eslint .` / `tsc --noEmit` | Quét regex `PRIVATE_KEY`, `TOKEN`, `API_KEY` |
| **Python** | `pip-audit` hoặc `safety check` | `ruff check .` / `bandit -r src/` | Quét regex secret trong `.env` & files |
| **Go** | `govulncheck ./...` | `golangci-lint run` / `go vet ./...` | Quét secret trong `internal/` |
| **Rust** | `cargo audit` | `cargo clippy -- -D warnings` | Quét secret trong `src/` |

---

## 4. Bảng Kiểm Tra Nghiệm Thu (Empirical Verification Checklist)

Trước khi claim hoàn thành bất kỳ task nào, Agent phải tự rà soát bảng checklist:

- [ ] Đã chạy lệnh test thực tế trong terminal và in bằng chứng ra màn hình?
- [ ] Test có thực sự kiểm tra logic nghiệp vụ và các trường hợp lỗi biên (Edge-cases)?
- [ ] Không có assertion sáo rỗng (`expect(true).toBe(true)`) hay mock toàn bộ?
- [ ] Đã chạy linter / typecheck với kết quả exit code 0?
- [ ] Đã chạy lệnh audit bảo mật (SCA / SAST) và không còn lỗi Critical/High?
- [ ] Không có secret / password / key nào vô tình bị lưu vào mã nguồn?
