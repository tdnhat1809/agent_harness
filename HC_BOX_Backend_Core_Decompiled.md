# HC BOX Backend Core Architecture & Decompiled Specification

Tài liệu mổ xẻ chi tiết tầng **Backend nhị phân Go (Compiled & Obfuscated)** của **HC BOX.exe** (Image kích thước ~92MB sau uncompress trong RAM).

---

## 1. Bản chất Kỹ thuật của Tệp Thực thi Backend (Go Runtime & Bundler)

* **Ngôn ngữ & Runtime**: Ứng dụng được viết bằng **Go 1.26** kết hợp cgo gọi các thư viện C++ (OpenCV 4.13, libimobiledevice, wintun).
* **Cơ chế đóng gói**:
  - Không có file backend dạng mã nguồn mở rời rạc (`.py` hay `.js`) trên ổ cứng. Toàn bộ backend đã được biên dịch thành mã máy x86-64 native PE.
  - Sử dụng **Garble / ProGuard-like Go Obfuscator**: Các package và symbol name được băm thành các chuỗi ngẫu nhiên (ví dụ `GgCSvBYaSQt` cho Gin Web Framework, `Ad5zBSa` cho Wails Desktop Framework, `vlWxIrg` cho usbmuxd/iOS driver).
  - Tích hợp **Go standard `embed.FS`**: Toàn bộ UI Vue 3 nằm trong struct `embed.FS` nhúng thẳng vào phân vùng data của file `.exe`.

---

## 2. Các Service & Port Chạy Ngầm (Active Microservices)

Khi chạy, `HC BOX.exe` khởi động 3 tiến trình mạng cục bộ (Local Networking Stack):

### A. HTTP REST API Server (`http://127.0.0.1:20080`)
Framework sử dụng: **Gin Web Framework** (gói `GgCSvBYaSQt`).
Các endpoint chính được dịch ngược từ router:
1. `POST /api/auth/login`: Xác thực tài khoản người dùng.
2. `POST /api/auth/register`: Đăng ký tài khoản.
3. `GET  /api/auth/version-check`: Kiểm tra phiên bản mới từ server cloud.
4. `GET  /api/user/info`: Lấy thông tin user, gói cước (`currentPlan`, `maxConnections`).
5. `GET  /api/device/app-icon?udid={udid}&bundleID={bundle}`: Trích xuất icon ứng dụng trực tiếp từ điện thoại.
6. `GET  /api/role/list`, `GET /api/user/list`: Quản lý phân quyền nội bộ.

### B. Control & Command WebSocket Hub (`ws://127.0.0.1:28848/ws?token={jwt}`)
- Đóng vai trò là **Message Broker trung tâm** giữa UI và các worker điều khiển.
- **Heartbeat & Authentication**:
  - Client gửi query parameter `token={accessToken}` khi mở kết nối.
  - Định dạng tin nhắn: JSON packet chứa `command`, `requestId`, `payload`.
- **Nhiệm vụ chính**:
  - Nhận lệnh đồng bộ (`syncTouch`, `syncKey`, `syncScroll`).
  - Gửi thông báo trạng thái kết nối của từng thiết bị (`connected`, `disconnected`, `usb_connect_status`).
  - Điều phối các tác vụ chạy theo lô (Auto-click, mở link, chạy kịch bản tự động).

### C. Video Streaming Server (`ws://127.0.0.1:18848/scrcpy`)
- Kênh truyền video tốc độ cao cho từng thiết bị Android.
- URL định dạng: `ws://127.0.0.1:18848/scrcpy?udid={SERIAL}&port={H264_LOCAL_PORT}`
- **Giao thức đóng gói Video**:
  - Header mở đầu stream: Magic bytes `scrcpy_initial` (chuỗi ASCII 14 bytes) + 64 bytes tên thiết bị (`DEVICE_NAME`) + kích thước hiển thị (`displayInfo`: width, height, rotation).
  - Dữ liệu video tiếp theo: Chuỗi **Raw H.264 NALU byte stream** (chứa các NALU type 7: SPS, type 8: PPS, type 5: IDR Keyframe, type 1: Delta frame).
- Đối với iOS: Kênh stream chạy qua `ws://127.0.0.1:{PORT}/h264` với định dạng `raw` H.264 stream.

---

## 3. Kiến trúc Điều khiển Phần cứng Chi tiết (Hardware Bridge Layer)

Backend thực hiện điều khiển 2 nền tảng hoàn toàn khác nhau thông qua 2 subsystem:

### A. Subsystem Điều khiển Android
1. **Khởi tạo kết nối**:
   - Backend gọi `resources/adb/adb.exe forward tcp:{LOCAL_PORT} localabstract:scrcpy`.
   - Đẩy `resources/scrcpy/scrcpy-server.jar` vào `/data/local/tmp/scrcpy-server.jar`.
   - Chạy lệnh khởi động server trên điện thoại qua ADB shell:
     ```bash
     app_process / com.genymobile.scrcpy.Server 2.4 \
       audio=false \
       control=true \
       cleanup=true \
       max_size=1080 \
       bit_rate=4000000 \
       max_fps=60 \
       tunnel_forward=true \
       send_device_meta=true \
       send_frame_meta=false \
       send_dummy_byte=true
     ```
2. **Kênh Điều khiển (Control Socket)**:
   - Khi frontend gửi sự kiện cảm ứng (Touch Event), backend chuyển đổi thành gói nhị phân gửi vào Scrcpy control socket:
     - `Byte 0`: `SC_CONTROL_MSG_TYPE_INJECT_TOUCH_EVENT` (0x02).
     - `Byte 1`: Action (`0 = AMOTION_EVENT_ACTION_DOWN`, `1 = UP`, `2 = MOVE`).
     - `Byte 2-9`: Pointer ID (64-bit int).
     - `Byte 10-13`: Tọa độ X (32-bit int).
     - `Byte 14-17`: Tọa độ Y (32-bit int).
     - `Byte 18-19`: Screen Width (16-bit int).
     - `Byte 20-21`: Screen Height (16-bit int).
     - `Byte 22-23`: Pressure (16-bit float).
     - `Byte 24-27`: Action button / buttons.

3. **Gõ phím & Clipboard**:
   - Sử dụng `resources/keyboardservice.apk` cài trực tiếp vào Android để hỗ trợ gõ tiếng Việt / UTF-8 không bị mất dấu hay giật lag thông qua Intent broadcast.

### B. Subsystem Điều khiển iOS
1. **USBMuxd & Lockdown Layer**:
   - Được implement trực tiếp trong Go qua package dịch ngược `vlWxIrg`:
     - `vlWxIrg/usbmuxconnection.go`: Lắng nghe daemon Apple Mobile Device qua socket `127.0.0.1:27015`.
     - `vlWxIrg/lockdown.go`: Thực hiện handshake, trao đổi chứng chỉ cặp khóa (Pairing record trong `%ALLUSERSPROFILE%\Apple\Lockdown`).
     - `vlWxIrg/startservice.go`: Kích hoạt dịch vụ truyền dữ liệu.
2. **Tự động hóa cảm ứng & WebDriverAgent**:
   - Backend nhúng các endpoint tương thích Appium / WDA:
     - `/wda/device/info`
     - `/x/activeAppInfo`
     - `/x/apps/activate`
     - `/x/deactivateApp`
     - `/x/setPasteboard`
     - `/x/getPasteboard`
     - `/wda/touch/perform` (Thực hiện chuỗi thao tác bấm, vuốt).
3. **Màn hình iOS**:
   - Sử dụng `resources/ios.exe` kết hợp `iproxy.exe` để forward video stream từ dịch vụ AirPlay / QuickTime mirroring qua cổng WebSocket local.

---

## 4. Kiến trúc Nhận diện Thị giác & AI OCR (Vision Layer)

Tệp `resources/OCR/OCR.dll` (kích thước ~45MB) cùng các DLL OpenCV 4.13:
- Được backend Go gọi qua giao tiếp **cgo / ctypes**.
- Nhận input là mảng byte ảnh JPEG/BGR từ video frame của một thiết bị.
- Sử dụng mô hình **PaddleOCR / ONNX Runtime** nhúng sẵn trong `OCR.dll` để trả về danh sách bounding box `[x, y, width, height]` và chuỗi text tiếng Việt/Trung/Anh tương ứng.
- Phục vụ cho tính năng Auto-Task: Tự động tìm nút "Bỏ qua", "Đăng nhập", "Tiếp tục" trên màn hình điện thoại để tự động click mà không cần tọa độ cứng.

---

## 5. Hướng Dẫn Tự Code 1 Backend Clone Đơn Giản Bằng Python (Minimal Clone)

Mày có thể dựng lại toàn bộ backend này bằng Python với cấu trúc chỉ khoảng 150 dòng:
1. **Scrcpy Client**: Dùng thư viện `scrcpy-client` hoặc `adbutils` trong Python:
   ```python
   import scrcpy
   from adbutils import adb

   device = adb.device("99281FFAZ000ST")
   client = scrcpy.Client(device=device, max_fps=60, bitrate=4000000)

   def on_frame(frame):
       # frame là numpy array (BGR), có thể nén JPEG hoặc encode H.264
       pass

   client.add_listener(scrcpy.EVENT_FRAME, on_frame)
   client.start(threaded=True)
   ```
2. **WebSocket Hub**: Dùng `FastAPI` + `websockets` nhận sự kiện từ frontend Vue và gọi `client.control.touch(x, y, action)`.
3. **Đồng bộ hàng loạt**: Duyệt vòng lặp `for c in clients: c.control.touch(x, y, action)` để đạt được tính năng Sync Control tương tự HC BOX.

