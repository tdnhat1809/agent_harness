# HC BOX Architecture, Reverse Engineering & Re-implementation Guide

Tài liệu giải mã toàn bộ cấu trúc mã nguồn, cơ chế hoạt động và kiến trúc hệ thống của **HC BOX 1.0.9** để phục vụ việc tự xây dựng bản clone / tool điều khiển Phone Farm độc lập.

---

## 1. Tổng quan Kiến trúc Hệ thống (System Architecture)

HC BOX được xây dựng theo mô hình **Hybrid Desktop Architecture**:
1. **Frontend UI (Presentation Layer)**:
   - Framework: **Vue 3 + Vite + Element Plus + Pinia Store**.
   - Chạy trên runtime Microsoft Edge **WebView2** (nhúng vào cửa sổ native).
2. **Backend Daemon (Core Service Layer)**:
   - Viết bằng **Go (Golang)** và **C/C++ native DLLs** (OpenCV, imobiledevice, libusb, wintun).
   - Đóng vai trò là một Local Microservices Server chạy ngầm trên máy:
     - **HTTP REST API Server**: Port `http://localhost:20080` (quản lý device list, config, task, script).
     - **WebSocket Stream & Control Server**: Port `ws://localhost:28848/ws?token={access_token}` (truyền stream video H.264/JPEG và gửi lệnh touch/key đồng bộ).
3. **Hardware & Device Bridge Layer**:
   - **Android**: `resources/adb/adb.exe` + `resources/scrcpy/scrcpy-server.jar` + `resources/keyboardservice.apk`.
   - **iOS**: `resources/ios.exe` + `resources/iproxy.exe` + `resources/tidevice.exe` + bộ thư viện `libimobiledevice-1.0.dll`, `libusbmuxd-2.0.dll`.
   - **AI/Vision**: `resources/OCR/OCR.dll` kết hợp OpenCV 4.13 (`libopencv_core4130.dll`, `libopencv_imgproc4130.dll`, etc.) để nhận diện chữ và tự động click trên màn hình thiết bị.

---

## 2. Cấu trúc Mã nguồn Frontend (Trích xuất từ Vue Component Tree)

Toàn bộ cây thư mục UI và Component gốc của app:

```
src/
├── api/
│   ├── auth.js            # /api/auth/login, /api/auth/register, /api/auth/version-check
│   └── user.js            # /api/user/info
├── router/
│   └── routes.js          # Khai báo đường dẫn menu & dynamic routes
├── store/
│   ├── modules/
│   │   ├── user.js        # Pinia store lưu trữ session: currentPlan, maxConnections (đã bypass 100)
│   │   ├── setting.js     # Giao diện: isFocusMode, menuOpen, showWorkTab, themeStyle
│   │   └── device.js      # Danh sách thiết bị, selectedUdids, globalMasterUdid, syncControl
├── views/
│   ├── auth/
│   │   ├── login/index.vue
│   │   ├── register/index.vue
│   │   └── forget-password/index.vue
│   ├── dashboard/
│   │   └── console/
│   │       ├── index.vue                       # Giao diện chính chứa lưới màn hình Phone Farm
│   │       ├── DeviceRightPanel.vue            # Bảng điều khiển tham số (Rotate, FPS, Quality, Sliders)
│   │       ├── FloatingDeviceWindow.vue        # Cửa sổ pop-up phóng to 1 máy độc lập
│   │       ├── QuickPhrasesManager.vue         # Quản lý câu mẫu / text gõ nhanh
│   │       ├── QuickPhrasesSidebar.vue         # Thanh trượt nhập nhanh text vào điện thoại
│   │       └── components/
│   │           ├── AutoClickConfig.vue         # Cấu hình auto-click theo tọa độ / chu kỳ
│   │           ├── AutoClickStop.vue
│   │           ├── AutoScrollConfig.vue        # Cấu hình tự động lướt (TikTok / Reels / Shorts)
│   │           ├── AutoScrollStop.vue
│   │           ├── OpenUrlDialog.vue           # Mở đồng loạt link trên trình duyệt điện thoại
│   │           └── RunScriptDialog.vue         # Chạy script tự động hóa trên danh sách máy chọn
│   ├── device/
│   │   ├── list/index.vue                      # Bảng quản lý danh sách UDID / IP / Trạng thái
│   │   └── screen/
│   │       ├── AndroidScreen.vue               # Canvas/WebGL render stream từ scrcpy
│   │       └── IOSScreen.vue                   # Canvas render stream màn hình iPhone
│   ├── system-setting/
│   │   ├── screen-cast/index.vue               # Cài đặt tốc độ khung hình, bitrate, chế độ OTG
│   │   └── shortcut-keys/index.vue             # Phím tắt điều khiển (F11 focus, Esc, Sync on/off)
│   ├── script/
│   │   └── list/index.vue                      # Quản lý kho kịch bản farm
│   ├── task/
│   │   ├── list/index.vue                      # Lịch trình chạy farm tự động
│   │   ├── logs/index.vue                      # Nhật ký log quá trình thao tác
│   │   └── script-config/index.vue
│   └── system/
│       ├── user-center/index.vue               # Trung tâm kích hoạt bản quyền & tài khoản
│       ├── user/index.vue
│       └── role/index.vue
└── utils/
    └── StreamConnectionManager.js              # Quản lý WebSocket kết nối tới backend Go
```

---

## 3. Cơ chế Đồng bộ Điều khiển (Sync Control Engine)

Toàn bộ cơ chế đồng bộ được thực hiện dựa trên mô hình **Master - Slave Topology**:
1. **Master Assignment**:
   - Khi người dùng bật `Đồng bộ điều khiển` (`syncControlEnabled = true`), thiết bị đầu tiên hoặc thiết bị được click chọn sẽ trở thành `globalMasterUdid` (hoặc `groupMasterUdid` nếu chia nhóm).
   - Biến trạng thái: `isControlMaster = true`.
2. **Touch/Event Interception**:
   - `AndroidScreen.vue` hoặc `IOSScreen.vue` lắng nghe sự kiện trên Canvas: `mousedown`, `mousemove`, `mouseup`, `wheel`, `keydown`.
   - Tính toán tọa độ chuẩn hóa: 
     $$X_{norm} = \frac{X_{click}}{Width_{canvas}}, \quad Y_{norm} = \frac{Y_{click}}{Height_{canvas}}$$
3. **Dispatching via WebSocket (`StreamConnectionManager`)**:
   - Lệnh gửi qua socket `ws://localhost:28848/ws`:
     ```json
     {
       "command": "syncTouch",
       "masterUdid": "UDID_CUA_MAY_CHINH",
       "targetUdids": ["UDID_SLAVE_1", "UDID_SLAVE_2", ...],
       "action": "down|move|up",
       "x": 0.542,
       "y": 0.318,
       "pressure": 1.0
     }
     ```
4. **Backend Execution**:
   - Đối với **Android**: Backend chuyển tiếp lệnh thành socket injection vào `scrcpy-server` (giao thức binary điều khiển của scrcpy: `INJECT_TOUCH_EVENT` với type, id, position, pressure).
   - Đối với **iOS**: Backend gửi qua lệnh WebDriverAgent / XCTest runner thông qua kết nối USBmuxd của `resources/ios.exe`.

---

## 4. Cách Tự Build Phiên Bản Nâng Cấp Riêng (Independent Implementation)

Để tạo một phần mềm điều khiển Phone Farm độc lập không phụ thuộc vào HC BOX:
1. **Frontend**: Dùng **Vue 3 + Vite + TailwindCSS** (hoặc Electron / Wails / Tauri).
2. **Android Streaming Engine**:
   - Sử dụng trực tiếp `scrcpy` (Open Source của Genymobile). Đẩy `scrcpy-server.jar` vào thiết bị qua ADB:
     ```bash
     adb push scrcpy-server.jar /data/local/tmp/scrcpy-server.jar
     adb forward tcp:27183 localabstract:scrcpy
     adb shell CLASSPATH=/data/local/tmp/scrcpy-server.jar app_process / com.genymobile.scrcpy.Server 2.4 ...
     ```
   - Nhận video stream H.264 qua raw socket và giải mã trên frontend bằng **WebCodecs API** (`VideoDecoder`) hoặc thư viện `jmuxer` / `Broadway.js` để render trực tiếp lên HTML5 Canvas với độ trễ < 30ms.
3. **iOS Streaming Engine**:
   - Dùng `libimobiledevice` + kết nối qua cổng USBMuxd để lấy AVPlayer/MJPEG stream từ XCTest / WebDriverAgent.
4. **Broadcast Touch Controller**:
   - Tạo một WebSocket Hub trung gian bằng Go hoặc Python (FastAPI / WebSockets). Nhận tọa độ chuột từ máy Master và broadcast song song ra hàng loạt socket con tới từng thiết bị qua USB/ADB.

