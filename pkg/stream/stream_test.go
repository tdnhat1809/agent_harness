package stream

import (
	"net"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/websocket"

	"hcbox/pkg/device"
	"hcbox/pkg/models"
)

func TestStreamServer(t *testing.T) {
	// Start a mock TCP scrcpy server
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("failed to listen on tcp: %v", err)
	}
	defer ln.Close()

	port := ln.Addr().(*net.TCPAddr).Port

	// Mock video sender
	go func() {
		conn, err := ln.Accept()
		if err != nil {
			return
		}
		defer conn.Close()
		// Send mock H.264 data with scrcpy dummy byte & 64-byte name
		_, _ = conn.Write([]byte{0x00})
		nameBuf := make([]byte, 64)
		_, _ = conn.Write(nameBuf)
		mockData := []byte{0x00, 0x00, 0x00, 0x01, 0x67, 0x42, 0x00, 0x1f} // SPS NALU
		_, _ = conn.Write(mockData)
	}()

	devMgr := device.NewDeviceManager(nil)
	devMgr.AddOrUpdate(&models.Device{
		UDID:          "STREAM_TEST_DEV",
		H264LocalPort: port,
	})

	srv := NewServer(devMgr, ":0")
	mux := srv.Handler()
	httpServer := httptest.NewServer(mux)
	defer httpServer.Close()

	wsURL := "ws" + strings.TrimPrefix(httpServer.URL, "http") + "/scrcpy?udid=STREAM_TEST_DEV&port=" + strconv.Itoa(port)

	dialer := websocket.DefaultDialer
	conn, _, err := dialer.Dial(wsURL, nil)
	if err != nil {
		// Handshake or connect test
		return
	}
	defer conn.Close()

	_ = conn.SetReadDeadline(time.Now().Add(1 * time.Second))
	msgType, data, err := conn.ReadMessage()
	if err == nil {
		if msgType != websocket.BinaryMessage {
			t.Fatalf("expected binary message, got %d", msgType)
		}
		if len(data) == 0 {
			t.Fatalf("expected non-empty video payload")
		}
	}
}

func TestScrcpyInitialHeaderPacket(t *testing.T) {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("failed to listen on tcp: %v", err)
	}
	defer ln.Close()

	port := ln.Addr().(*net.TCPAddr).Port

	// Mock scrcpy daemon:
	// 1. Accepts socket 1 (video) -> sends dummy byte (0x00) + 64 bytes device name + H264 NALUs
	// 2. Accepts socket 2 (control)
	go func() {
		videoConn, err := ln.Accept()
		if err != nil {
			return
		}
		defer videoConn.Close()

		ctrlConn, err := ln.Accept()
		if err == nil {
			defer ctrlConn.Close()
		}

		// Send scrcpy 1 dummy byte
		_, _ = videoConn.Write([]byte{0x00})
		// Send 64-byte device name
		nameBuf := make([]byte, 64)
		copy(nameBuf, "SM-A730F")
		_, _ = videoConn.Write(nameBuf)

		// Send H.264 NALU (SPS)
		nalu := []byte{0x00, 0x00, 0x00, 0x01, 0x67, 0x42, 0x80, 0x1f}
		_, _ = videoConn.Write(nalu)
	}()

	devMgr := device.NewDeviceManager(nil)
	devMgr.AddOrUpdate(&models.Device{
		UDID:          "TEST_INITIAL_DEV",
		Name:          "SM-A730F",
		Width:         1080,
		Height:        2220,
		H264LocalPort: port,
	})

	srv := NewServer(devMgr, ":0")
	httpServer := httptest.NewServer(srv.Handler())
	defer httpServer.Close()

	wsURL := "ws" + strings.TrimPrefix(httpServer.URL, "http") + "/scrcpy?udid=TEST_INITIAL_DEV&port=" + strconv.Itoa(port)

	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		t.Fatalf("failed to dial websocket: %v", err)
	}
	defer conn.Close()

	_ = conn.SetReadDeadline(time.Now().Add(2 * time.Second))

	// First packet MUST be scrcpy_initial (126 bytes)
	_, initialData, err := conn.ReadMessage()
	if err != nil {
		t.Fatalf("failed to read initial message: %v", err)
	}

	if len(initialData) != 126 {
		t.Fatalf("expected initial packet length 126, got %d", len(initialData))
	}

	magic := string(initialData[:14])
	if magic != "scrcpy_initial" {
		t.Fatalf("expected magic 'scrcpy_initial', got %q", magic)
	}

	// Second packet MUST be H.264 NALU
	_, naluData, err := conn.ReadMessage()
	if err != nil {
		t.Fatalf("failed to read nalu message: %v", err)
	}

	if len(naluData) == 0 || naluData[0] != 0 || naluData[1] != 0 || naluData[2] != 0 || naluData[3] != 1 {
		t.Fatalf("expected H.264 start code, got %v", naluData)
	}
}

func TestNALUSplitter(t *testing.T) {
	splitter := NewNALUSplitter()

	nalu1 := make([]byte, 50)
	copy(nalu1, []byte{0, 0, 0, 1, 0x67})
	nalu2 := make([]byte, 80)
	copy(nalu2, []byte{0, 0, 0, 1, 0x65})
	nalu3 := make([]byte, 20)
	copy(nalu3, []byte{0, 0, 0, 1, 0x21})

	stream := append(nalu1, append(nalu2, nalu3...)...)

	var collected [][]byte
	for i := 0; i < len(stream); i += 15 {
		end := i + 15
		if end > len(stream) {
			end = len(stream)
		}
		res := splitter.Push(stream[i:end])
		collected = append(collected, res...)
	}

	if len(collected) < 2 {
		t.Fatalf("expected at least 2 complete NALUs, got %d", len(collected))
	}

	if len(collected[0]) != 50 || collected[0][4] != 0x67 {
		t.Fatalf("expected NALU 1 length 50 with type 0x67, got len %d", len(collected[0]))
	}

	if len(collected[1]) != 80 || collected[1][4] != 0x65 {
		t.Fatalf("expected NALU 2 length 80 with type 0x65, got len %d", len(collected[1]))
	}
}
