# Rule — Guardrails & Engineering Mandates

These guardrails are strictly active for all engineering tasks, prompts, and problem-solving workflows:

## 1. Nói Chuyện Bằng Số Liệu Thực Tế (Empirical Metrics Only)
- Chỉ đưa ra nhận định, đánh giá và kết luận dựa trên **dữ liệu đo lường thực tế** (exit codes, compiler diagnostics, stdout/stderr logs, latency ms, memory usage, test pass rates, HTTP status codes, SQL query plans).
- Tuyệt đối không phỏng đoán, không đưa ra tuyên bố cảm tính hoặc lý thuyết suông khi chưa có kết quả chạy thực tế từ môi trường.

## 2. Viết Test Trước Khi Làm (Strict TDD / Red-Green-Refactor)
- Bắt buộc viết bài kiểm thử tự động (unit test / integration test / regression test) mô tả hành vi mong muốn và chạy để chứng minh nó **FAIL (RED)** trước khi viết bất kỳ dòng code logic chính nào.
- Chỉ viết lượng code tối thiểu để làm test **PASS (GREEN)**, sau đó **REFACTOR** tối ưu hoá mà vẫn giữ nguyên contract.

## 3. Tự Động Spawn Subagent Đối Chiếu Ngữ Cảnh (Autonomous Context Cross-Check)
- Khi xử lý các luồng phức tạp hoặc nghi ngờ có xung đột chéo giữa các service/module/package, chủ động chia tách và spawn subagent độc lập để:
  - So sánh đối chiếu hợp đồng interface giữa các tầng (`packages/contracts`, `bff`, `services`, `apps`).
  - Kiểm tra độc lập, đa chiều không bị ảnh hưởng bởi thiên kiến ngữ cảnh hiện tại.

## 4. Vòng Lặp Liên Tục Đến Khi Đạt Mục Tiêu (Continuous Convergence Loop)
- Thực hiện quy trình lặp liên tục:
  `Chẩn đoán ➔ Viết Test RED ➔ Implement GREEN ➔ Verify Proof ➔ Đo lường số liệu`
- Không dừng lại hoặc bỏ cuộc giữa chừng; lặp lại cho đến khi toàn bộ mục tiêu (Goal) đã đề ra được chứng minh hoàn thành 100% bằng số liệu thực thi.
