package ws

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/websocket"

	"hcbox/pkg/device"
	"hcbox/pkg/models"
)

func TestWebSocketHub(t *testing.T) {
	devMgr := device.NewDeviceManager(nil)
	devMgr.AddOrUpdate(&models.Device{
		UDID:             "WS_TEST_DEV",
		Name:             "Farm Device",
		UsbConnectStatus: true,
		Width:            1080,
		Height:           2400,
	})

	hub := NewHub(devMgr, ":0")
	server := httptest.NewServer(hub.Handler())
	defer server.Close()

	wsURL := "ws" + strings.TrimPrefix(server.URL, "http") + "/ws?token=test_token"

	dialer := websocket.DefaultDialer
	conn, _, err := dialer.Dial(wsURL, nil)
	if err != nil {
		t.Fatalf("failed to dial websocket: %v", err)
	}
	defer conn.Close()

	// 1. First message must be auth confirmation
	_, msg, err := conn.ReadMessage()
	if err != nil {
		t.Fatalf("failed to read auth message: %v", err)
	}

	var authResp models.WsOutMessage
	if err := json.Unmarshal(msg, &authResp); err != nil {
		t.Fatalf("failed to unmarshal auth: %v", err)
	}
	if authResp.Action != "auth" || authResp.StatusCode != 200 {
		t.Fatalf("expected auth 200, got %+v", authResp)
	}

	// 2. Test ping -> pong
	if err := conn.WriteMessage(websocket.TextMessage, []byte("ping")); err != nil {
		t.Fatalf("failed to write ping: %v", err)
	}
	_, msg, err = conn.ReadMessage()
	if err != nil || string(msg) != "pong" {
		t.Fatalf("expected pong, got %s, err: %v", string(msg), err)
	}

	// 3. Test intConfig
	req := models.WsInMessage{Command: "intConfig"}
	b, _ := json.Marshal(req)
	_ = conn.WriteMessage(websocket.TextMessage, b)

	_, msg, err = conn.ReadMessage()
	if err != nil {
		t.Fatalf("failed to read intConfig resp: %v", err)
	}
	var out models.WsOutMessage
	_ = json.Unmarshal(msg, &out)
	if out.Command != "init-config" {
		t.Fatalf("expected init-config command, got %s", out.Command)
	}

	// 4. Test touchDown event dispatching
	touchReq := models.WsInMessage{
		Command: "touchDown",
		Devices: []string{"WS_TEST_DEV"},
		Point:   []float64{0.5, 0.5},
	}
	bTouch, _ := json.Marshal(touchReq)
	_ = conn.WriteMessage(websocket.TextMessage, bTouch)
	time.Sleep(50 * time.Millisecond)

	// Clean up
	_ = hub.Close()
}
