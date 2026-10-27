# ✂️ Context & Observation Pruning Directive

> **Invariant 5: Empirical Metrics Over Raw Dumps**  
> **Goal**: Ngăn chặn tình trạng phình to ngữ cảnh (Context Bloat) và suy giảm độ tập trung (Attention Drift) trong các phiên làm việc kéo dài.

---

## 1. Cơ chế Cắt tỉa Đầu ra Thực thi (Observation & Log Pruning)

Khi chạy các lệnh build, test, linter hoặc security scan:
1. **Cấm đổ toàn bộ Log**: Tuyệt đối không copy-paste nguyên văn hàng trăm hay hàng nghìn dòng output thành công vào câu trả lời của Agent.
2. **Head/Tail Truncation (8+8)**: Chỉ giữ lại 8 dòng đầu tiên (để xác nhận lệnh đã chạy) và 8 dòng cuối cùng (để xác nhận exit code và tổng kết).
3. **Chỉ trích xuất Failure Delta**: Nếu bài test thất bại, chỉ trích xuất đúng:
   - Tên tệp test và số dòng bị fail.
   - Thông điệp lỗi trực tiếp (`AssertionError`, `TypeError`, `NullPointerException`).
   - 3-5 dòng stack trace nội bộ (loại bỏ stack trace của framework/node_modules).

---

## 2. Tối ưu hóa Git Diff (Diff Delta Minimization)

Khi kiểm tra các thay đổi mã nguồn trước khi commit:
- Ưu tiên dùng `git status --short` và `git diff --stat` để có cái nhìn tổng quan.
- Khi cần xem chi tiết thay đổi, sử dụng context hunk nhỏ:
  ```bash
  git diff -U1 <file>
  ```
- Không đọc lại các tệp không nằm trong phạm vi thay đổi (blast radius).

---

## 3. Tóm tắt Quỹ đạo Từng bước (Trajectory Compaction)

Trong các chuỗi giải quyết vấn đề phức tạp (Root Cause Investigation):
- Không lặp lại các giả thuyết đã bị bác bỏ trong các turn trước.
- Khi một checkpoint trong `docs/plans/active/` hoàn thành, Agent chỉ tóm tắt 2 dòng:
  - *Đã thực hiện*: [Hành động]
  - *Bằng chứng*: [Exit code 0 / Test metric đo được]

---

## 4. Ngưỡng Cảnh báo Ngữ cảnh (Compaction Milestone)

Khi cuộc trò chuyện kéo dài hoặc sau khi giải quyết xong một tính năng lớn:
- Agent chủ động chạy kịch bản:
  ```powershell
  .\scripts\checkpoint.ps1 -Completed "..." -NextSteps "..."
  ```
- Khuyến nghị người dùng mở phiên làm việc mới (Fresh Session) để phục hồi 100% dung lượng suy luận của mô hình.
