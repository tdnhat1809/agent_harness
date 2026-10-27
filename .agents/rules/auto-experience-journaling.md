# Auto-Experience Journaling Rule (Tự Động Ghi Kinh Nghiệm Sau Task)

Quy tắc bắt buộc Agent tự động đúc kết và ghi nhận kinh nghiệm kỹ thuật vào hệ thống bộ nhớ dài hạn, chống "mất trí nhớ theo phiên" (Session Amnesia) mà không cần người dùng phải nhắc nhở thủ công.

---

## 1. Điều kiện Kích hoạt Bắt buộc (Mandatory Triggers)

Agent **BẮT BUỘC** thực hiện quy trình ghi nhận kinh nghiệm trước khi tuyên bố hoàn thành (`Claim Completion`) khi gặp một trong các trường hợp sau:
1. **Sửa lỗi / Dập Bug (Defect & Failure Resolution)**:
   - Đã xử lý xong một lỗi build, compile error, test failure, runtime exception hoặc logic bug.
2. **Phát hiện cạm bẫy môi trường / Thư viện (Environment Gotchas & Quirks)**:
   - Gặp hành vi bất ngờ của dependency, encoding issue, OS difference (Windows vs Linux), hoặc API quirks.
3. **Hoàn thành tính năng có quyết định kiến trúc mới (Feature & Architecture Milestone)**:
   - Đã chốt một giải pháp kỹ thuật, API contract, hoặc luồng dữ liệu mới.

> ⛔ **Quy tắc chống loãng ngữ cảnh (Anti-Noise Guard)**:
> Không ghi nhận những câu hỏi đáp thông tin thuần túy (read-only queries), chỉnh sửa typo đơn thuần hoặc thao tác kiểm tra trạng thái không làm thay đổi logic hệ thống.

---

## 2. Thao tác Cơ học Bắt buộc (Mechanical Execution)

Trước khi gửi phản hồi nghiệm thu cuối cùng cho người dùng:

1. **Ghi nhận sự cố & bài học bất biến**:
   - Chạy script ghi nhận tự động:
     - **Windows (PowerShell)**:
       ```powershell
       powershell -ExecutionPolicy Bypass -File .\scripts\record-lesson.ps1 -Symptom "<Triệu chứng lỗi>" -RootCause "<Nguyên nhân gốc rễ>" -Prevention "<Biện pháp phòng ngừa bất biến>"
       ```
     - **Linux / MacOS (Bash)**:
       ```bash
       ./scripts/record-lesson.sh "<Symptom>" "<RootCause>" "<Prevention>"
       ```
   - Script sẽ tự động gán mã `ERR-XXX` và cập nhật trực tiếp vào [`docs/memory/failure-journal.md`](file:///docs/memory/failure-journal.md).

2. **Cập nhật Checkpoint phiên (Session Scratchpad)**:
   - Nếu hoàn thành một chặng quan trọng trong kế hoạch, chạy:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\scripts\checkpoint.ps1 -CompletedTask "<Nhiệm vụ vừa xong>" -NextStep "<Các bước tiếp theo>"
     ```

---

## 3. Tiêu chuẩn Nội dung Bài học (Empirical Quality Standard)

Mọi bài học được ghi nhận phải tuân thủ nghiêm ngặt 3 trường thông tin:
- **Symptom (Triệu chứng)**: Mô tả chính xác thông báo lỗi, exit code hoặc hiện tượng sai lệch đo lường được.
- **Root Cause (Nguyên nhân gốc rễ)**: Cô lập chính xác vị trí và lý do kỹ thuật phát sinh lỗi, tuyệt đối không đoán mò.
- **Prevention (Biện pháp phòng ngừa)**: Đưa ra quy tắc hoặc kỹ thuật cụ thể để các Agent trong tương lai không bao giờ lặp lại lỗi này.

---

## 4. Báo cáo Minh chứng trong Output

Trong báo cáo hoàn thành gửi người dùng, Agent phải trích dẫn mã định danh kinh nghiệm đã ghi:
> *"📌 [Auto-Experience Logged]: Đã tự động ghi nhận bài học `ERR-XXX` vào `docs/memory/failure-journal.md`."*
