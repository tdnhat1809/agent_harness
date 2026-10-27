# 📓 Engineering Failure Journal & Lessons Learned

> **"Learn From Every Outcome" — Invariant 6**  
> Bản ghi nhớ các lỗi kiến trúc, bug khó, sai lầm thiết kế và bài học xương máu.
> Mọi AI Agent khi khởi tạo phiên mới BẮT BUỘC đọc file này để không bao giờ lặp lại sai lầm trong quá khứ.

---

## 📋 Bảng Tra cứu Sự cố & Bài học (Incident Log)

| ID | Ngày | Triệu chứng lỗi (Symptoms) | Nguyên nhân gốc rễ (Root Cause) | Quy tắc phòng ngừa bất biến (Never Do Again) |
|---|---|---|---|---|
| `ERR-002` | 2026-10-27 | Agent khong tu dong ghi kinh nghiem vao memory sau khi hoan thanh task | Thieu hook bat buoc trong pre_complete va thieu chi thi cuong che trong cac entrypoint AGENTS.md | Them luat auto-experience-journaling vao pre_complete va quy dinh trong 5 Guardrails Mandates bat buoc chay record-lesson truoc khi nghiem thu |
| `ERR-001` | 2026-10-27 | Pre-commit hook tự bắt chính mình khi quét diff regex API key | File script chứa chuỗi regex pattern khớp với chính bộ lọc quét nhạy cảm | Thêm pathspec exclude `:(exclude)scripts/git-hooks/*` vào bộ quét diff |

---

## 🔍 Chi tiết Phân tích Sự cố (Detailed Root Cause Analyses)

### `ERR-001`: Self-Referential Regex Match in Git Hook
- **Mô tả**: Khi cập nhật file `pre-commit`, git diff chứa regex chuỗi `BEGIN <PRIVATE> KEY`, dẫn tới script tự động chặn chính commit của mình.
- **Nguyên nhân gốc rễ**: Lệnh `git diff --cached` mặc định quét toàn bộ staged files, bao gồm cả file định nghĩa luật kiểm tra bảo mật.
- **Giải pháp dứt điểm**: Luôn áp dụng exclude pathspec cho các script kiểm tra bảo mật nội bộ:
  ```bash
  git diff --cached -U0 -- ":(exclude)scripts/git-hooks/*"
  ```
- **Bài học rút ra**: Các công cụ bảo mật nội bộ cần cô lập phạm vi quét của chính nó để tránh bẫy tự phản chiếu (self-referential trap).

---

## 🛠️ Hướng dẫn ghi bài học mới

Sử dụng kịch bản dòng lệnh:
```powershell
.\scripts\record-lesson.ps1 -Symptom "Mô tả lỗi" -RootCause "Nguyên nhân gốc rễ" -Prevention "Quy tắc không lặp lại"
```
hoặc trên Linux/macOS:
```bash
./scripts/record-lesson.sh "Mô tả lỗi" "Nguyên nhân gốc rễ" "Quy tắc không lặp lại"
```


### `ERR-002`: Agent khong tu dong ghi kinh nghiem vao memory sau khi hoan thanh task
- **Date**: 2026-10-27
- **Symptom**: Agent khong tu dong ghi kinh nghiem vao memory sau khi hoan thanh task
- **Root Cause**: Thieu hook bat buoc trong pre_complete va thieu chi thi cuong che trong cac entrypoint AGENTS.md
- **Prevention Rule**: Them luat auto-experience-journaling vao pre_complete va quy dinh trong 5 Guardrails Mandates bat buoc chay record-lesson truoc khi nghiem thu

