package device

import (
	"bytes"
	"net"
	"testing"

	"hcbox/pkg/models"
	"hcbox/pkg/scrcpy"
)

type dummyConn struct {
	net.Conn
	written bytes.Buffer
}

func (d *dummyConn) Write(b []byte) (n int, err error) {
	return d.written.Write(b)
}

func (d *dummyConn) Close() error {
	return nil
}

func TestDeviceManager(t *testing.T) {
	mgr := NewDeviceManager(nil)

	dev := &models.Device{
		UDID:              "TEST_DEV_01",
		Name:              "Test Device",
		Platform:          "android",
		UsbConnectStatus:  true,
		H264LocalPort:     27183,
		H264WebSocketPort: 18848,
		Width:             1080,
		Height:            1920,
		Status:            "online",
	}

	mgr.AddOrUpdate(dev)

	got, found := mgr.GetDevice("TEST_DEV_01")
	if !found || got.Name != "Test Device" {
		t.Fatalf("expected device found with name Test Device")
	}

	all := mgr.GetAllDevices()
	if len(all) != 1 {
		t.Fatalf("expected 1 device, got %d", len(all))
	}

	// Test touch injection through mock socket
	mockConn := &dummyConn{}
	mgr.SetControlSocket("TEST_DEV_01", mockConn)

	// Inject normalized coordinates (0.5, 0.5) -> should become (540, 960)
	err := mgr.InjectTouch("TEST_DEV_01", scrcpy.MotionEventActionDown, []float64{0.5, 0.5})
	if err != nil {
		t.Fatalf("unexpected touch error: %v", err)
	}

	if mockConn.written.Len() != 28 {
		t.Fatalf("expected 28 bytes written, got %d", mockConn.written.Len())
	}

	// Test keycode injection
	mockConn.written.Reset()
	err = mgr.InjectKeycode("TEST_DEV_01", scrcpy.KeycodeHome)
	if err != nil {
		t.Fatalf("unexpected key error: %v", err)
	}
	// Down (14 bytes) + Up (14 bytes) = 28 bytes
	if mockConn.written.Len() != 28 {
		t.Fatalf("expected 28 bytes written for key down+up, got %d", mockConn.written.Len())
	}

	// Test text injection
	mockConn.written.Reset()
	err = mgr.InjectText("TEST_DEV_01", "hello")
	if err != nil {
		t.Fatalf("unexpected text error: %v", err)
	}
	if mockConn.written.Len() != 10 { // 5 byte header + 5 byte "hello"
		t.Fatalf("expected 10 bytes written for text, got %d", mockConn.written.Len())
	}

	// Test remove
	mgr.Remove("TEST_DEV_01")
	if len(mgr.GetAllDevices()) != 0 {
		t.Fatalf("expected 0 devices after remove")
	}
}

func TestNextPortAllocation(t *testing.T) {
	mgr := NewDeviceManager(nil)
	p1 := mgr.NextPort()
	p2 := mgr.NextPort()
	if p2 != p1+1 {
		t.Fatalf("expected sequential port allocation: %d, %d", p1, p2)
	}
}

func TestDeviceSwipe(t *testing.T) {
	mgr := NewDeviceManager(nil)
	dev := &models.Device{
		UDID:          "SWIPE_DEV",
		Width:         1080,
		Height:        2220,
		H264LocalPort: 27183,
	}
	mgr.AddOrUpdate(dev)

	mockConn := &dummyConn{}
	mgr.SetControlSocket("SWIPE_DEV", mockConn)

	err := mgr.Swipe("SWIPE_DEV", 0.5, 0.8, 0.5, 0.2, 50)
	if err != nil {
		t.Fatalf("unexpected swipe error: %v", err)
	}

	// Down + multiple Moves + Up = multiple 28-byte packets
	if mockConn.written.Len() < 28*3 {
		t.Fatalf("expected at least 3 touch packets for swipe, got %d bytes", mockConn.written.Len())
	}
}
