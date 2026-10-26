# Anti-Regression & UI Invariant Preservation Rule

Chống triệt để căn bệnh "được cái này hỏng cái kia" và "phá nát giao diện UI cũ" của AI Agent.

## 1. Khóa phạm vi tác động (Blast Radius Locking)
- Trước khi chỉnh sửa bất kỳ file nào, Agent phải xác định chính xác danh sách file thuộc phạm vi thay đổi (ghi trong `docs/plans/active/`).
- **Nghiêm cấm sửa lan man**: Tuyệt đối không tự ý chỉnh sửa, định dạng lại, hoặc thay đổi các file/component nằm ngoài phạm vi được giao.

## 2. Bảo vệ bất biến giao diện (UI Invariant Protection)
- **Không phá vỡ Styling đang có**: Khi thêm logic hoặc tính năng mới vào component UI:
  - Giữ nguyên cấu trúc layout, class CSS, padding, margin, border, animations hiện có.
  - Không thay thế giao diện bespoke/custom bằng các thẻ HTML mặc định hoặc template placeholder thô sơ.
  - Không xóa các import styles hoặc đổi tên biến CSS tokens trừ khi có yêu cầu dứt khoát từ người dùng.

## 3. Kiểm thử hồi quy bắt buộc (Zero-Regression Verification)
- Sau mỗi lần sửa code, Agent không chỉ chạy test cho tính năng mới mà **bắt buộc phải chạy toàn bộ test suite hiện có của module** để đảm bảo không làm gãy bất kỳ tính năng cũ nào.
- Nếu xuất hiện test fail ở tính năng cũ ➔ Lập tức hoàn tác (Revert) hoặc khắc phục ngay trước khi chuyển sang bước tiếp theo.
