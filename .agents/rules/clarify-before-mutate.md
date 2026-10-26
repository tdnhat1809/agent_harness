# Clarify-Before-Mutate Rule (Cấm Làm Bừa Khi Thiếu Thông Tin)

Quy tắc ngăn chặn việc Agent tự ý suy đoán, đưa ra giả định sai lầm và tự tiện sửa code khi yêu cầu còn mơ hồ.

## 1. Dừng lại khi thiếu Thẩm quyền hoặc Thông số cốt lõi
Nếu yêu cầu của người dùng thiếu một trong các thông số sau, Agent **BẮT BUỘC PHẢI DỪNG LẠI VÀ HỎI**, không được phép tự bịa:
- **Hợp đồng dữ liệu & Kiểu dữ liệu**: Ví dụ thêm trường dữ liệu nhưng không rõ kiểu `string`, `UUID`, hay `enum`.
- **Ranh giới bảo mật & Phân quyền**: Ví dụ thêm API nhưng không rõ endpoint public hay private, ai có quyền truy cập.
- **Quota & Giới hạn**: Ví dụ rate limit bao nhiêu requests/phút, timeout bao nhiêu giây.
- **Có từ 2 phương án kiến trúc đối nghịch**: Ví dụ phân vân giữa polling hay websocket, giữa migration kiểu A hay B.

## 2. Tiêu chuẩn câu hỏi làm rõ
- Câu hỏi phải **ngắn gọn, trực diện, đưa ra từ 2–3 lựa chọn cụ thể** kèm tradeoff ngắn để người dùng chỉ cần chọn 1 hoặc 2.
- Không hỏi những câu vụn vặt mà có thể tự suy luận chắc chắn từ codebase hiện tại.
- Một khi người dùng đã chốt lựa chọn ➔ Lập tức ghi vào `docs/decisions/` để không bao giờ hỏi lại lần thứ hai.
