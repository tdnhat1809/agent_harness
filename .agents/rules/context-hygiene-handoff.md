# Context Hygiene & Checkpoint Handoff Rule

Chống hiện tượng "Agent bị ngáo, quên luật, sinh ảo giác" khi phiên hội thoại (context window) kéo dài quá mức.

## 1. Chia nhỏ công việc thành Checkpoints nguyên tử (Atomic Checkpoints)
- Mọi công việc phức tạp phải được chia thành các bước nhỏ từ 2 đến 5 phút trong file kế hoạch `docs/plans/active/<ten-task>.md`.
- Mỗi checkpoint phải có tiêu chí nghiệm thu rõ ràng: test nào pass, file nào được tạo.
- Sau khi hoàn thành mỗi checkpoint: Cập nhật ngay trạng thái `[x] Đã hoàn thành` kèm log bằng chứng vào file plan.

## 2. Quản lý dung lượng ngữ cảnh (Context Window Hygiene)
- **Không dồn nhiều việc lớn vào 1 prompt**: Mỗi prompt chỉ giải quyết từ 1 đến tối đa 2 nhiệm vụ cụ thể.
- **Tránh nhồi nhét log dài vào chat**: Sử dụng file đệm `docs/scratchpad.md` để ghi nhận các log terminal dài, stack traces, kết quả profiling thay vì in hàng nghìn dòng vào cửa sổ chat làm nghẽn context.

## 3. Chủ động đề xuất mở Hội thoại mới (Fresh Session Handoff)
- Khi một phiên làm việc đã trải qua nhiều lượt trao đổi phức tạp hoặc hoàn thành một cột mốc lớn (Milestone):
  - Agent phải chủ động thông báo:
    > *"Milestone X đã hoàn tất và lưu trữ toàn bộ trạng thái vào `docs/plans/active/<name>.md`. Để đảm bảo context luôn sạch 100% và tránh AI bị quá tải, bạn có thể mở một cuộc hội thoại mới (New Chat) và yêu cầu: 'Tiếp tục Milestone tiếp theo trong docs/plans/active/<name>.md'."*
- Trong phiên mới, Agent chỉ cần đọc file plan để tiếp tục ngay lập tức mà không bị mất dấu hay lẫn lộn ngữ cảnh cũ.
