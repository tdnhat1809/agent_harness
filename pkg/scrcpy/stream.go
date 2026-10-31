package scrcpy

import (
	"encoding/binary"
	"errors"
	"io"
)

// StreamHeader represents the initial metadata received when connecting to scrcpy video socket
type StreamHeader struct {
	DeviceName string
	Width      uint32
	Height     uint32
}

// ReadStreamHeader parses the opening header from scrcpy video connection
func ReadStreamHeader(r io.Reader) (*StreamHeader, error) {
	// scrcpy 2.0+ starts with dummy byte / metadata if configured
	// Standard scrcpy sends:
	// 64 bytes: Device Name (null-padded string)
	// 4 bytes: Width (uint32)
	// 4 bytes: Height (uint32)
	headerBuf := make([]byte, 64+4+4)
	if _, err := io.ReadFull(r, headerBuf); err != nil {
		return nil, errors.New("failed to read scrcpy stream header: " + err.Error())
	}

	nameBytes := headerBuf[:64]
	end := 0
	for end < len(nameBytes) && nameBytes[end] != 0 {
		end++
	}
	deviceName := string(nameBytes[:end])

	width := binary.BigEndian.Uint32(headerBuf[64:68])
	height := binary.BigEndian.Uint32(headerBuf[68:72])

	return &StreamHeader{
		DeviceName: deviceName,
		Width:      width,
		Height:     height,
	}, nil
}
