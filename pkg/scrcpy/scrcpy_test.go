package scrcpy

import (
	"bytes"
	"encoding/binary"
	"testing"
)

func TestEncodeTouchEvent(t *testing.T) {
	action := byte(MotionEventActionDown)
	var pointerID uint64 = 0xFFFFFFFFFFFFFFFF
	var x uint32 = 540
	var y uint32 = 960
	var width uint16 = 1080
	var height uint16 = 1920
	var pressure float32 = 1.0
	var buttons uint32 = MotionEventButtonPrimary

	pkt := EncodeTouchEvent(action, pointerID, x, y, width, height, pressure, buttons)
	if len(pkt) != 28 {
		t.Fatalf("expected 28 bytes, got %d", len(pkt))
	}
	if pkt[0] != ControlMsgTypeInjectTouchEvent {
		t.Fatalf("expected msg type 0x02, got 0x%02x", pkt[0])
	}
	if pkt[1] != action {
		t.Fatalf("expected action %d, got %d", action, pkt[1])
	}

	gotPointerID := binary.BigEndian.Uint64(pkt[2:10])
	if gotPointerID != pointerID {
		t.Fatalf("expected pointerID 0x%x, got 0x%x", pointerID, gotPointerID)
	}

	gotX := binary.BigEndian.Uint32(pkt[10:14])
	if gotX != x {
		t.Fatalf("expected x %d, got %d", x, gotX)
	}

	gotY := binary.BigEndian.Uint32(pkt[14:18])
	if gotY != y {
		t.Fatalf("expected y %d, got %d", y, gotY)
	}

	gotW := binary.BigEndian.Uint16(pkt[18:20])
	if gotW != width {
		t.Fatalf("expected width %d, got %d", width, gotW)
	}

	gotH := binary.BigEndian.Uint16(pkt[20:22])
	if gotH != height {
		t.Fatalf("expected height %d, got %d", height, gotH)
	}

	gotButtons := binary.BigEndian.Uint32(pkt[24:28])
	if gotButtons != buttons {
		t.Fatalf("expected buttons %d, got %d", buttons, gotButtons)
	}
}

func TestEncodeKeycode(t *testing.T) {
	action := byte(0) // Down
	keyCode := KeycodeHome
	pkt := EncodeKeycode(action, keyCode, 0, 0)
	if len(pkt) != 14 {
		t.Fatalf("expected 14 bytes, got %d", len(pkt))
	}
	if pkt[0] != ControlMsgTypeInjectKeycode {
		t.Fatalf("expected msg type 0x00, got 0x%02x", pkt[0])
	}
	if pkt[1] != action {
		t.Fatalf("expected action %d, got %d", action, pkt[1])
	}
	gotKey := binary.BigEndian.Uint32(pkt[2:6])
	if gotKey != keyCode {
		t.Fatalf("expected keycode %d, got %d", keyCode, gotKey)
	}
}

func TestEncodeText(t *testing.T) {
	text := "Xin chào Việt Nam 6767"
	pkt := EncodeText(text)
	if pkt[0] != ControlMsgTypeInjectText {
		t.Fatalf("expected msg type 0x01, got 0x%02x", pkt[0])
	}
	textLen := binary.BigEndian.Uint32(pkt[1:5])
	if int(textLen) != len([]byte(text)) {
		t.Fatalf("expected length %d, got %d", len([]byte(text)), textLen)
	}
	if string(pkt[5:]) != text {
		t.Fatalf("expected text %s, got %s", text, string(pkt[5:]))
	}
}

func TestReadStreamHeader(t *testing.T) {
	buf := make([]byte, 72)
	copy(buf[:64], []byte("Redmi_Note_12_Turbo\x00"))
	binary.BigEndian.PutUint32(buf[64:68], 1080)
	binary.BigEndian.PutUint32(buf[68:72], 2400)

	header, err := ReadStreamHeader(bytes.NewReader(buf))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if header.DeviceName != "Redmi_Note_12_Turbo" {
		t.Fatalf("expected device name Redmi_Note_12_Turbo, got %s", header.DeviceName)
	}
	if header.Width != 1080 || header.Height != 2400 {
		t.Fatalf("expected 1080x2400, got %dx%d", header.Width, header.Height)
	}
}
