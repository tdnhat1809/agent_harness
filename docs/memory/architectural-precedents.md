# 🏛️ Architectural Precedents & Project Conventions

> **Mục đích**: Lưu trữ các quyết định kỹ thuật, quy chuẩn kiến trúc và thông số hệ thống đã được Người dùng phê duyệt.  
> **Quy tắc Agent**: Khi thấy một vấn đề kỹ thuật đã được ghi nhận trong tài liệu này, Agent **TUYỆT ĐỐI KHÔNG HỎI LẠI** người dùng, mà phải tự động tuân thủ 100%.

---

## 1. Công nghệ & Stack chuẩn hóa (Standard Stack)

- **Môi trường chạy**: Node.js v22+, Python 3.12+, Go 1.22+, Rust 1.80+ (Tùy stack phát hiện của dự án).
- **Trình duyệt tự động & Crawling**: Luôn chạy ở chế độ headless (`headless: true`). Cấm bật cửa sổ GUI ngoại trừ khi người dùng yêu cầu rõ ràng.
- **Quy chuẩn mã nguồn**:
  - Tuân thủ nghiêm ngặt Strict TDD (Red-Green-Refactor).
  - Không sử dụng văn mẫu AI sáo rỗng (*delve, tapestry, paramount...*).
  - Giao tiếp trực diện theo phong cách Staff / Principal Engineer.

---

## 2. Thông số & Ranh giới Hệ thống (System Boundaries)

| Hạng mục | Quy chuẩn đã phê duyệt | Lý do & Căn cứ |
|---|---|---|
| **Cổng mạng mặc định** | Không bind tùy tiện các port ngoài dải cho phép | Tuân thủ bảo mật mạng nội bộ |
| **Bảo vệ Secret** | Toàn bộ credentials phải nằm trong biến môi trường hoặc vault | Chặn đứng rò rỉ lên Git qua hook `pre-commit` |
| **Quản lý Task** | Task lớn (>2 tệp, thay đổi kiến trúc) bắt buộc tạo Plan trong `docs/plans/active/` | Bắt buộc kiểm tra checkpoint trước khi merge |

---

## 3. Các quyết định đã thông qua (Approved Technical Precedents)

- **2026-10-27**: Tích hợp toàn diện bộ kỹ năng REA (Reverse Engineer Anything) từ `morluto/rea` vào hệ thống kỹ năng mở rộng.
- **2026-10-27**: Kích hoạt cơ chế Modular Profile cho installer (`minimal`, `web-fullstack`, `security-re`, `all`, `auto`).
- **2026-10-27**: Ép kỷ luật cơ học bằng Git Hooks tự động trong `.git/hooks/pre-commit` và `pre-push`.
