package scrcpy

import (
	"encoding/binary"
	"math"
)

// Scrcpy Control Message Types
const (
	ControlMsgTypeInjectKeycode               byte = 0x00
	ControlMsgTypeInjectText                  byte = 0x01
	ControlMsgTypeInjectTouchEvent            byte = 0x02
	ControlMsgTypeScrollAt                    byte = 0x03
	ControlMsgTypeBackOrScreenOn              byte = 0x04
	ControlMsgTypeExpandNotificationPanel     byte = 0x05
	ControlMsgTypeCollapseNotificationPanel   byte = 0x06
	ControlMsgTypeGetClipboard                byte = 0x07
	ControlMsgTypeSetClipboard                byte = 0x08
	ControlMsgTypeSetScreenPowerMode          byte = 0x09
	ControlMsgTypeRotateDevice                byte = 0x0a
)

// Android MotionEvent Actions
const (
	MotionEventActionDown = 0
	MotionEventActionUp   = 1
	MotionEventActionMove = 2
)

// Android KeyCodes
const (
	KeycodeHome       uint32 = 3
	KeycodeBack       uint32 = 4
	KeycodeVolumeUp   uint32 = 24
	KeycodeVolumeDown uint32 = 25
	KeycodePower      uint32 = 26
	KeycodeEnter      uint32 = 66
	KeycodeDel        uint32 = 67
	KeycodeAppSwitch  uint32 = 187
)

// MotionEvent Buttons
const (
	MotionEventButtonPrimary uint32 = 1
)

// EncodeTouchEvent serializes a touch event into 28-byte binary format for scrcpy-server
// Format:
// Byte 0: MsgType (0x02)
// Byte 1: Action (0=Down, 1=Up, 2=Move)
// Byte 2..9: PointerId (int64)
// Byte 10..13: X (uint32)
// Byte 14..17: Y (uint32)
// Byte 18..19: Screen Width (uint16)
// Byte 20..21: Screen Height (uint16)
// Byte 22..23: Pressure (uint16 float 0..1 mapped to 0..65535)
// Byte 24..27: Action button (uint32)
func EncodeTouchEvent(action byte, pointerID uint64, x, y uint32, width, height uint16, pressure float32, buttons uint32) []byte {
	buf := make([]byte, 28)
	buf[0] = ControlMsgTypeInjectTouchEvent
	buf[1] = action
	binary.BigEndian.PutUint64(buf[2:10], pointerID)
	binary.BigEndian.PutUint32(buf[10:14], x)
	binary.BigEndian.PutUint32(buf[14:18], y)
	binary.BigEndian.PutUint16(buf[18:20], width)
	binary.BigEndian.PutUint16(buf[20:22], height)

	// Pressure normalized to uint16
	pressureNorm := uint16(math.Min(math.Max(float64(pressure), 0.0), 1.0) * 65535.0)
	binary.BigEndian.PutUint16(buf[22:24], pressureNorm)

	binary.BigEndian.PutUint32(buf[24:28], buttons)
	return buf
}

// EncodeKeycode serializes a key event into 14-byte binary format for scrcpy-server
// Format:
// Byte 0: MsgType (0x00)
// Byte 1: Action (0=Down, 1=Up)
// Byte 2..5: Keycode (uint32)
// Byte 6..9: Repeat (uint32)
// Byte 10..13: MetaState (uint32)
func EncodeKeycode(action byte, keyCode, repeat, meta uint32) []byte {
	buf := make([]byte, 14)
	buf[0] = ControlMsgTypeInjectKeycode
	buf[1] = action
	binary.BigEndian.PutUint32(buf[2:6], keyCode)
	binary.BigEndian.PutUint32(buf[6:10], repeat)
	binary.BigEndian.PutUint32(buf[10:14], meta)
	return buf
}

// EncodeText serializes a text insertion message for scrcpy-server
// Format:
// Byte 0: MsgType (0x01)
// Byte 1..4: Text Length (uint32)
// Byte 5..: UTF-8 encoded text bytes
func EncodeText(text string) []byte {
	textBytes := []byte(text)
	buf := make([]byte, 5+len(textBytes))
	buf[0] = ControlMsgTypeInjectText
	binary.BigEndian.PutUint32(buf[1:5], uint32(len(textBytes)))
	copy(buf[5:], textBytes)
	return buf
}

// EncodeScroll serializes a scroll event into 21-byte binary format for scrcpy-server
func EncodeScroll(x, y uint32, width, height uint16, hScroll, vScroll int32) []byte {
	buf := make([]byte, 21)
	buf[0] = ControlMsgTypeScrollAt
	binary.BigEndian.PutUint32(buf[1:5], x)
	binary.BigEndian.PutUint32(buf[5:9], y)
	binary.BigEndian.PutUint16(buf[9:11], width)
	binary.BigEndian.PutUint16(buf[11:13], height)
	binary.BigEndian.PutUint32(buf[13:17], uint32(hScroll))
	binary.BigEndian.PutUint32(buf[17:21], uint32(vScroll))
	return buf
}
