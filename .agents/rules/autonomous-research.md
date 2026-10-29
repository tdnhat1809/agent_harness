# Autonomous Web & GitHub Research Protocol

Quy tắc bất khả xâm phạm về **Tính trung thực tri thức (Epistemic Honesty)**: Bắt buộc Agent phải chủ động tra cứu Google, GitHub và Registry trước khi viết code khi gặp thư viện mới, repo lạ, hoặc API chưa chắc chắn 100%.

---

## 1. Nguyên Tắc Cốt Lõi: Cấm Tuyệt Đối Bịa Đặt API (Zero Hallucinated API)

### ⛔ Cấm tự đoán mò (The "Guessing Anti-Pattern"):
- Khi gặp:
  * Một thư viện vừa cập nhật phiên bản lớn (ví dụ: Next.js 15, Tailwind v4, Pydantic v2, Prisma 6, Bun 1.2).
  * Một repository GitHub lạ do người dùng cung cấp hoặc được dẫn link.
  * Một SDK/Package bên thứ 3 không có sẵn trong tài liệu nội bộ.
- **TUYỆT ĐỐI CẤM**: Tự bịa tên hàm, tự đoán tham số truyền vào, hoặc áp dụng cú pháp của phiên bản cũ.

---

## 2. Quy Trình Tra Cứu Tự Hành 3 Kênh (3-Channel Research Workflow)

Khi chưa chắc chắn 100% về chữ ký hàm (function signature) hoặc cấu trúc module, Agent **BẮT BUỘC** thực hiện tra cứu qua 3 kênh trước khi chỉnh sửa file:

### Kênh 1: Khai thác Thực tế qua GitHub CLI (`gh`)
Máy chủ đã tích hợp sẵn GitHub CLI (`gh`). Agent phải tận dụng để đọc mã nguồn thật từ chính tác giả:
1. **Đọc tổng quan repo và hướng dẫn**:
   ```bash
   gh repo view <owner>/<repo>
   ```
2. **Khai thác Code Mẫu (Code Search - Vũ khí mạnh nhất)**:
   Tìm kiếm chính xác cách các lập trình viên hoặc tác giả gọi hàm đó trong repo:
   ```bash
   gh search code "<tên-hàm-hoặc-class> repo:<owner>/<repo>"
   ```
3. **Tìm kiếm repo tương tự nếu cần giải pháp mẫu**:
   ```bash
   gh search repos "<từ-khóa-bài-toán>" --sort stars --limit 5
   ```

### Kênh 2: Tra cứu Tài liệu Chính thức & Breaking Changes (`search_web`)
Sử dụng công cụ tìm kiếm web (`search_web`) với các câu truy vấn có độ chính xác cao:
- Cú pháp tìm docs: `site:docs.<library>.com <tên-phương-thức>`
- Cú pháp tìm breaking changes: `"<library> v<version>" migration guide breaking changes`
- Cú pháp tìm lỗi runtime: `"<thông-báo-lỗi-chính-xác>" github issue resolved`

### Kênh 3: Bộ Công cụ Trợ Thủ Cục bộ (`scripts/inspect-package.ps1` / `.sh`)
Sử dụng bộ công cụ tích hợp sẵn trong Harness để lấy nhanh metadata mà không cần rời terminal:
```powershell
# Tra cứu package NPM:
powershell -ExecutionPolicy Bypass -File .\scripts\inspect-package.ps1 -Npm "<package-name>"

# Tra cứu package PyPI (Python):
powershell -ExecutionPolicy Bypass -File .\scripts\inspect-package.ps1 -Pypi "<package-name>"

# Tra cứu repo GitHub:
powershell -ExecutionPolicy Bypass -File .\scripts\inspect-package.ps1 -GitHub "<owner/repo>"
```

---

## 3. Căn Cứ Vào Định Nghĩa Kiểu Cục Bộ (Ground Truth in Type Definitions)

Đối với các dự án đã cài đặt dependency vào thư mục nội bộ:
- Với TypeScript/JavaScript: Luôn đọc file định nghĩa kiểu `.d.ts` trong `node_modules/<package>/...` để xem chính xác các tham số bắt buộc và kiểu trả về.
- Với Python: Kiểm tra `py.typed` hoặc dùng `python -c "import <lib>; help(<lib>.<func>)"` để đọc docstring thật.
- Với Go/Rust: Đọc trực tiếp interface hoặc struct definition trong module.

---

## 4. Minh Chứng Nguồn Gốc trong Báo Cáo Nghiệm Thu

Khi sử dụng một API mới từ repo hoặc package lạ, trong báo cáo cho người dùng, Agent phải trích dẫn nguồn gốc xác minh:
> *"📌 [Verified Authority]: Cú pháp của `<function_name>` đã được xác thực từ tài liệu chính thức / GitHub repo `<owner/repo>`."*
