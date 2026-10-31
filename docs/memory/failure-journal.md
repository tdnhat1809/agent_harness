# 📓 Engineering Failure Journal & Lessons Learned

> **"Learn From Every Outcome" — Invariant 6**  
> Bản ghi nhớ các lỗi kiến trúc, bug khó, sai lầm thiết kế và bài học xương máu.
> Mọi AI Agent khi khởi tạo phiên mới BẮT BUỘC đọc file này để không bao giờ lặp lại sai lầm trong quá khứ.

---

## 📋 Bảng Tra cứu Sự cố & Bài học (Incident Log)

| ID | Ngày | Triệu chứng lỗi (Symptoms) | Nguyên nhân gốc rễ (Root Cause) | Quy tắc phòng ngừa bất biến (Never Do Again) |
|---|---|---|---|---|
| `ERR-009` | 2026-10-31 | Lower half of mirrored phone screen was blurry and smeared with a white translucent overlay | TCP stream chunking severed H.264 NALUs across packet boundaries. The WebCodecs player splitNALUs failed to assemble fragmented slices, feeding partial IDR/P-frame macroblocks into hardware decoder which rendered corrupted lower slices as white smears | Use Annex-B NALUSplitter on backend to buffer TCP stream and emit only complete NAL units per WebSocket binary message, and increase bitrate to 8Mbps |
| `ERR-008` | 2026-10-31 | Phone screen turned black after switching windows or backgrounding | WebCodecs player set videoElement opacity to 0 and relied on requestVideoFrameCallback which stalls when window is not actively rendering to display | Set videoElement default opacity to 1 and trigger first frame render callback synchronously upon decoding |
| `ERR-007` | 2026-10-31 | Mouse clicks and touch/swipe gestures on screen mirrored device did not control the phone | scrcpy-server was launched with max_size=1080 which downscaled video size to 528x1080, but touch injection sent the native 1080x2220 size, causing scrcpy to reject all touch packets with 'Ignore touch event, it was generated for a different device size' | Launch scrcpy-server with native resolution (max_size=0) matching device screen resolution, and support swipe gestures in control hub |
| `ERR-006` | 2026-10-31 | HC_BOX screen cast displays disconnected broken-chain icon despite USB connected | Backend did not send the 126-byte scrcpy_initial packet expected by frontend WebCodecs player, and a fake virtual device caused port conflict on 27183 | Synthesize 126-byte scrcpy_initial header on WebSocket connect and remove virtual device seeds |
| `ERR-005` | 2026-10-29 | Agent sinh UI re tien voi emoji icon va tu bia dat API khi gap thu vien repo GitHub moi | Thieu luat cuong che Zero-Emoji trong UI va thieu quy trinh tu dong tra cuu docs/code mau qua GitHub CLI va Web Search truoc khi code | Cai dat luat anti-ai-slop-ui.md, autonomous-research.md va tich hop inspect-package.ps1 vao pre_task/post_edit hooks |
| `ERR-004` | 2026-10-29 | Agent bo sot loi B trong prompt da muc tieu va chi test qua loa happy path roi bao cao xong som | Thieu ma tran phan ra muc tieu Turn 1, thieu rao chan kiem thu 3 tang (negative + full suite), va thieu su kiem tra cheo tu subagent QA | Ap dung luat zero-drop-multi-goal.md vao pre_task/pre_complete, bat buoc xuat Proof-of-Execution Matrix kem exit code 0 va trieu tap @qa khi gap task da loi |
| `ERR-003` | 2026-10-29 | Agent ngung ghi failure-journal trong cac phien lam viec dai khi sua bug nghiem trong | Chi thi prompt bi suy giam chu y (Lost-in-the-Middle) khi context dai, thieu mechanical gate chan lenh git commit | Cai dat commit-msg hook tu dong block commit fix: neu thieu failure-journal.md, va them defect transition prompt vao verify.ps1 |
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

### `ERR-003`: Agent ngung ghi failure-journal trong cac phien lam viec dai khi sua bug nghiem trong
- **Date**: 2026-10-29
- **Symptom**: Agent ngung ghi failure-journal trong cac phien lam viec dai khi sua bug nghiem trong
- **Root Cause**: Chi thi prompt bi suy giam chu y (Lost-in-the-Middle) khi context dai, thieu mechanical gate chan lenh git commit
- **Prevention Rule**: Cai dat commit-msg hook tu dong block commit fix: neu thieu failure-journal.md, va them defect transition prompt vao verify.ps1

### `ERR-004`: Agent bo sot loi B trong prompt da muc tieu va chi test qua loa happy path roi bao cao xong som
- **Date**: 2026-10-29
- **Symptom**: Agent bo sot loi B trong prompt da muc tieu va chi test qua loa happy path roi bao cao xong som
- **Root Cause**: Thieu ma tran phan ra muc tieu Turn 1, thieu rao chan kiem thu 3 tang (negative + full suite), va thieu su kiem tra cheo tu subagent QA
- **Prevention Rule**: Ap dung luat zero-drop-multi-goal.md vao pre_task/pre_complete, bat buoc xuat Proof-of-Execution Matrix kem exit code 0 va trieu tap @qa khi gap task da loi

### `ERR-005`: Agent sinh UI re tien voi emoji icon va tu bia dat API khi gap thu vien repo GitHub moi
- **Date**: 2026-10-29
- **Symptom**: Agent sinh UI re tien voi emoji icon va tu bia dat API khi gap thu vien repo GitHub moi
- **Root Cause**: Thieu luat cuong che Zero-Emoji trong UI va thieu quy trinh tu dong tra cuu docs/code mau qua GitHub CLI va Web Search truoc khi code
- **Prevention Rule**: Cai dat luat anti-ai-slop-ui.md, autonomous-research.md va tich hop inspect-package.ps1 vao pre_task/post_edit hooks

### `ERR-006`: HC_BOX screen cast displays disconnected broken-chain icon despite USB connected
- **Date**: 2026-10-31
- **Symptom**: HC_BOX screen cast displays disconnected broken-chain icon despite USB connected
- **Root Cause**: Backend did not send the 126-byte scrcpy_initial packet expected by frontend WebCodecs player, and a fake virtual device caused port conflict on 27183
- **Prevention Rule**: Synthesize 126-byte scrcpy_initial header on WebSocket connect and remove virtual device seeds
- **Details**: Fixed in pkg/stream/server.go, pkg/device/manager.go, main.go

### `ERR-007`: Mouse clicks and touch/swipe gestures on screen mirrored device did not control the phone
- **Date**: 2026-10-31
- **Symptom**: Mouse clicks and touch/swipe gestures on screen mirrored device did not control the phone
- **Root Cause**: scrcpy-server was launched with max_size=1080 which downscaled video size to 528x1080, but touch injection sent the native 1080x2220 size, causing scrcpy to reject all touch packets with 'Ignore touch event, it was generated for a different device size'
- **Prevention Rule**: Launch scrcpy-server with native resolution (max_size=0) matching device screen resolution, and support swipe gestures in control hub
- **Details**: Fixed in pkg/device/manager.go and pkg/ws/hub.go, verified with adb logcat and TestDeviceSwipe

### `ERR-008`: Phone screen turned black after switching windows or backgrounding
- **Date**: 2026-10-31
- **Symptom**: Phone screen turned black after switching windows or backgrounding
- **Root Cause**: WebCodecs player set videoElement opacity to 0 and relied on requestVideoFrameCallback which stalls when window is not actively rendering to display
- **Prevention Rule**: Set videoElement default opacity to 1 and trigger first frame render callback synchronously upon decoding
- **Details**: Fixed in extracted_source/assets/StreamConnectionManager-COg52LSp.js and pkg/device/manager.go

### `ERR-009`: Lower half of mirrored phone screen was blurry and smeared with a white translucent overlay
- **Date**: 2026-10-31
- **Symptom**: Lower half of mirrored phone screen was blurry and smeared with a white translucent overlay
- **Root Cause**: TCP stream chunking severed H.264 NALUs across packet boundaries. The WebCodecs player splitNALUs failed to assemble fragmented slices, feeding partial IDR/P-frame macroblocks into hardware decoder which rendered corrupted lower slices as white smears
- **Prevention Rule**: Use Annex-B NALUSplitter on backend to buffer TCP stream and emit only complete NAL units per WebSocket binary message, and increase bitrate to 8Mbps
- **Details**: Fixed in pkg/stream/server.go and pkg/device/manager.go, verified with live screen capture at 23:03

