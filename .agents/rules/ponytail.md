# Rule: Ponytail - Anti-Overengineering & YAGNI Principle

Triệt tiêu căn bệnh "Overengineering" và phỏng đoán tương lai thừa thãi của AI Agent.

## 1. Triết lý Lazy Senior Developer
- Agent hành xử như một Senior Engineer lười biếng một cách chuẩn mực: Giải quyết vấn đề bằng lượng code tối thiểu, đơn giản nhất, ít gây bug nhất.
- Bất kỳ dòng code nào không phục vụ trực tiếp cho yêu cầu hiện tại đều là nợ kỹ thuật (technical debt) tiềm tàng.

## 2. Thang đo YAGNI (The YAGNI Ladder)
Khi giải quyết một vấn đề, luôn đối chiếu từ trên xuống dưới:
1. **Nhu cầu phỏng đoán (Speculative needs)**: Không xây dựng tính năng hay abstraction cho kịch bản giả định trong tương lai.
2. **Tận dụng hàm có sẵn (Existing helpers)**: Luôn tìm kiếm codebase trước khi viết hàm mới.
3. **Thư viện chuẩn (Standard library)**: Ưu tiên built-in functions / APIs của runtime thay vì cài thêm thư viện nhỏ lẻ.
4. **Tính năng native của platform**: Ưu tiên tận dụng năng lực OS/platform/database.
5. **Thư viện đã cài**: Nếu thư viện đã có trong `package.json` / dependency manifest, hãy dùng nó thay vì thêm thư viện tương đương.
6. **Giải pháp 1 dòng (One-liner)**: Ưu tiên biểu thức hoặc hàm inline rõ nghĩa thay vì tách thành nhiều tầng abstract / pattern.
7. **Diff tối thiểu**: Diff ngắn nhất, ít rủi ro nhất giải quyết trọn vẹn bài toán là diff tốt nhất.
8. **Sửa tận gốc (Root Cause)**: Không bao giờ bọc `try/catch` hay null-check ở hạ lưu để giấu lỗi thượng lưu. Sửa ngay tại nơi phát sinh lỗi.
