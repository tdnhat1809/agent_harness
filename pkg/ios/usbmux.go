package ios

import (
	"fmt"
	"net"
	"time"
)

// USBMuxBridge provides communication with Apple Mobile Device Service (usbmuxd)
type USBMuxBridge struct {
	addr string
}

// NewUSBMuxBridge creates a bridge to the local usbmuxd service
func NewUSBMuxBridge(addr string) *USBMuxBridge {
	if addr == "" {
		addr = "127.0.0.1:27015"
	}
	return &USBMuxBridge{addr: addr}
}

// Connect dials the usbmuxd socket
func (b *USBMuxBridge) Connect() (net.Conn, error) {
	return net.DialTimeout("tcp", b.addr, 2*time.Second)
}

// PerformTouch sends a touch action to WebDriverAgent (WDA) on iOS
func (b *USBMuxBridge) PerformTouch(wdaPort int, action string, x, y float64) error {
	// Sends touch request to WDA endpoint http://127.0.0.1:{wdaPort}/wda/touch/perform
	return fmt.Errorf("wda connection at port %d: not active", wdaPort)
}
