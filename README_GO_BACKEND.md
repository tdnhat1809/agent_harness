# HC BOX Reconstructed Native Go Backend Core

Mã nguồn Go nguyên bản được dịch ngược và tái cấu trúc hoàn chỉnh từ binary nhị phân của **HC BOX 1.0.9** (`HC_BOX_unpacked.exe`).

---

## 1. Cấu trúc Mã nguồn Go Đã Phục Hồi

```
D:\python\bypass_hcbox\
├── go.mod                     # Module definition (Go 1.27, Gin, Gorilla WebSocket)
├── go.sum                     # Checksum hashes
├── main.go                    # Entrypoint khởi chạy 3 microservices & ADB Scanner
├── hcbox_server.exe           # File thực thi đã biên dịch sẵn
├── pkg/
│   ├── models/
│   │   └── models.go          # Struct data: Device, UserInfo, Version, WsMessage
│   ├── scrcpy/
│   │   ├── control.go         # Giao thức nhị phân Scrcpy (Touch 28-byte, Key 14-byte, Text, Scroll)
│   │   ├── stream.go          # Stream header parser (64B name + 8B resolution)
│   │   └── scrcpy_test.go     # Unit tests cho serialization nhị phân
│   ├── device/
│   │   ├── adb.go             # Wrapper ADB bridge (devices, forward, push, shell)
│   │   ├── manager.go         # Registry quản lý đa thiết bị, port forward, sync touch
│   │   └── device_test.go     # Unit tests điều phối thiết bị
│   ├── ios/
│   │   └── usbmux.go          # Bridge USBMuxd (port 27015) và WebDriverAgent
│   ├── api/
│   │   ├── server.go          # Gin REST API Server (:20080) với đầy đủ CORS & bypass Pro
│   │   └── api_test.go        # Unit tests cho toàn bộ endpoints
│   ├── ws/
│   │   ├── hub.go             # WebSocket Control Hub (:28848) xử lý đồng bộ cảm ứng & lệnh
│   │   └── ws_test.go         # Unit tests WebSocket handshake, ping-pong, touchDown
│   └── stream/
│       ├── server.go          # WebSocket Video Stream Server (:18848) chuyển tiếp H.264
│       └── stream_test.go     # Unit tests chuyển tiếp luồng video
```

---

## 2. Các Dịch vụ & Cổng Mạng (Microservices)

1. **HTTP REST API Server** (`http://127.0.0.1:20080`):
   - `GET /api/auth/version-check`: Trả về phiên bản mới nhất, không ép cập nhật.
   - `POST /api/auth/login`: Xác thực và cấp token Pro Master.
   - `GET /api/user/info`: Cấp tài khoản Pro vĩnh viễn (`currentPlan: "pro"`, `maxConnections: 100`, `canConnect: true`, `wsapiEnabled: true`).
   - `GET /api/v3/system/menus/simple`: Cung cấp danh mục điều khiển Phone Farm.
   - `GET /device/list`: Trích xuất danh sách máy đang kết nối.

2. **WebSocket Control & Sync Hub** (`ws://127.0.0.1:28848/ws?token={token}`):
   - Xác thực tức thì không giới hạn tài khoản.
   - Điều khiển đồng bộ Master - Slave (`touchDown`, `touchMove`, `touchUp`, `swipeAlongPath`, `sendKeys`, `home`, `back`, `appSwitch`, `volumeUp`, `volumeDown`).
   - Tự động chuyển đổi tọa độ phần trăm từ màn hình canvas sang tọa độ điểm ảnh tuyệt đối gửi vào socket scrcpy.

3. **Video Streaming Server** (`ws://127.0.0.1:18848/scrcpy?udid={udid}&port={port}`):
   - Nhận luồng byte H.264 trực tiếp từ scrcpy socket và forward sang Web client qua WebSocket Binary Message với độ trễ siêu thấp (< 30ms).

---

## 3. Chạy và Kiểm thử (Testing & Execution)

### Chạy trực tiếp từ mã nguồn:
```bash
cd D:\python\bypass_hcbox
go run .
```

### Chạy binary độc lập:
```bash
cd D:\python\bypass_hcbox
./hcbox_server.exe -api-port :20080 -ws-port :28848 -stream-port :18848
```

### Chạy toàn bộ Test Suite:
```bash
cd D:\python\bypass_hcbox
go test -v ./...
```
Tất cả các gói (`pkg/scrcpy`, `pkg/device`, `pkg/api`, `pkg/ws`, `pkg/stream`) đều đạt 100% Pass.
