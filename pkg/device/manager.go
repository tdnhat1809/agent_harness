package device

import (
	"fmt"
	"net"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"hcbox/pkg/models"
	"hcbox/pkg/scrcpy"
)

// DeviceManager maintains device registries, control connections, and multi-device dispatching
type DeviceManager struct {
	mu             sync.RWMutex
	devices        map[string]*models.Device
	controlSockets map[string]net.Conn
	adb            *ADBBridge
	portCounter    int
	portMu         sync.Mutex
}

// NewDeviceManager initializes a new DeviceManager instance
func NewDeviceManager(adb *ADBBridge) *DeviceManager {
	return &DeviceManager{
		devices:        make(map[string]*models.Device),
		controlSockets: make(map[string]net.Conn),
		adb:            adb,
		portCounter:    27183,
	}
}

// NextPort allocates an available local port for scrcpy forwarding
func (m *DeviceManager) NextPort() int {
	m.portMu.Lock()
	defer m.portMu.Unlock()
	p := m.portCounter
	m.portCounter++
	if m.portCounter > 28000 {
		m.portCounter = 27183
	}
	return p
}

// AddOrUpdate registers or updates a device state
func (m *DeviceManager) AddOrUpdate(dev *models.Device) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.devices[dev.UDID] = dev
}

// Remove unregisters a device
func (m *DeviceManager) Remove(udid string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if conn, ok := m.controlSockets[udid]; ok {
		_ = conn.Close()
		delete(m.controlSockets, udid)
	}
	delete(m.devices, udid)
}

// GetDevice retrieves a device by UDID
func (m *DeviceManager) GetDevice(udid string) (*models.Device, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	dev, ok := m.devices[udid]
	return dev, ok
}

// GetAllDevices returns all registered devices
func (m *DeviceManager) GetAllDevices() []*models.Device {
	m.mu.RLock()
	defer m.mu.RUnlock()
	list := make([]*models.Device, 0, len(m.devices))
	for _, dev := range m.devices {
		list = append(list, dev)
	}
	return list
}

// SetControlSocket attaches an open scrcpy control connection to a device
func (m *DeviceManager) SetControlSocket(udid string, conn net.Conn) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if old, exists := m.controlSockets[udid]; exists {
		_ = old.Close()
	}
	m.controlSockets[udid] = conn
}

// InjectTouch dispatches a touch event to a single device or a list of target devices
func (m *DeviceManager) InjectTouch(udid string, action byte, point []float64) error {
	m.mu.RLock()
	dev, exists := m.devices[udid]
	conn := m.controlSockets[udid]
	m.mu.RUnlock()

	if !exists || dev == nil {
		return fmt.Errorf("device %s not found", udid)
	}

	width := dev.Width
	height := dev.Height
	if width <= 0 {
		width = 1080
	}
	if height <= 0 {
		height = 2400
	}

	// Calculate absolute pixel coordinates from normalized floats (0.0 to 1.0)
	var xPx, yPx uint32
	if len(point) >= 2 {
		if point[0] <= 1.0 && point[1] <= 1.0 {
			xPx = uint32(point[0] * float64(width))
			yPx = uint32(point[1] * float64(height))
		} else {
			xPx = uint32(point[0])
			yPx = uint32(point[1])
		}
	}

	// 0xFFFFFFFFFFFFFFFF indicates single pointer touch in scrcpy
	packet := scrcpy.EncodeTouchEvent(
		action,
		0xFFFFFFFFFFFFFFFF,
		xPx,
		yPx,
		uint16(width),
		uint16(height),
		1.0,
		scrcpy.MotionEventButtonPrimary,
	)

	if conn != nil {
		_, err := conn.Write(packet)
		return err
	}
	return nil
}

// InjectKeycode dispatches key down and key up to the device
func (m *DeviceManager) InjectKeycode(udid string, keyCode uint32) error {
	m.mu.RLock()
	conn := m.controlSockets[udid]
	m.mu.RUnlock()

	if conn == nil {
		return nil
	}

	down := scrcpy.EncodeKeycode(0, keyCode, 0, 0)
	up := scrcpy.EncodeKeycode(1, keyCode, 0, 0)

	if _, err := conn.Write(down); err != nil {
		return err
	}
	time.Sleep(20 * time.Millisecond)
	_, err := conn.Write(up)
	return err
}

// InjectText inserts text into the target device
func (m *DeviceManager) InjectText(udid string, text string) error {
	m.mu.RLock()
	conn := m.controlSockets[udid]
	m.mu.RUnlock()

	if conn == nil {
		return nil
	}

	packet := scrcpy.EncodeText(text)
	_, err := conn.Write(packet)
	return err
}

// Swipe performs a swipe gesture between two normalized coordinates (0.0 to 1.0)
func (m *DeviceManager) Swipe(udid string, x1, y1, x2, y2 float64, durationMs int) error {
	steps := 10
	if durationMs <= 0 {
		durationMs = 200
	}
	stepDelay := time.Duration(durationMs/steps) * time.Millisecond

	_ = m.InjectTouch(udid, scrcpy.MotionEventActionDown, []float64{x1, y1})
	for i := 1; i <= steps; i++ {
		t := float64(i) / float64(steps)
		currX := x1 + (x2-x1)*t
		currY := y1 + (y2-y1)*t
		time.Sleep(stepDelay)
		_ = m.InjectTouch(udid, scrcpy.MotionEventActionMove, []float64{currX, currY})
	}
	time.Sleep(stepDelay)
	return m.InjectTouch(udid, scrcpy.MotionEventActionUp, []float64{x2, y2})
}

// IsScrcpyRunning checks if scrcpy is already active on the device
func (m *DeviceManager) IsScrcpyRunning(udid string) bool {
	if m.adb == nil {
		return false
	}
	out, err := m.adb.Shell(udid, "ps -A | grep -i com.genymobile.scrcpy.Server")
	return err == nil && strings.Contains(out, "app_process")
}

// EnsureForward makes sure the port forward is registered with adb
func (m *DeviceManager) EnsureForward(udid string, port int) error {
	if m.adb == nil {
		return nil
	}
	return m.adb.ForwardPort(udid, port, "localabstract:scrcpy")
}

// StartScrcpy initializes scrcpy-server on the Android device and creates forward sockets
func (m *DeviceManager) StartScrcpy(udid string) error {
	m.mu.Lock()
	dev, exists := m.devices[udid]
	if !exists {
		dev = &models.Device{
			UDID:             udid,
			RealSerial:       udid,
			Name:             "Samsung Phone " + udid,
			Model:            "Samsung Galaxy",
			Platform:         "android",
			UsbConnectStatus: true,
			ScrcpyStatus:     true,
			ConnectType:      "USB",
			H264LocalPort:    m.NextPort(),
			Width:            1072,
			Height:           2208,
			Status:           "online",
		}
		dev.StreamURL = fmt.Sprintf("ws://127.0.0.1:18848/scrcpy?udid=%s&port=%d", udid, dev.H264LocalPort)
		m.devices[udid] = dev
	} else {
		dev.ScrcpyStatus = true
		dev.UsbConnectStatus = true
		if dev.H264LocalPort <= 0 {
			dev.H264LocalPort = m.NextPort()
			dev.StreamURL = fmt.Sprintf("ws://127.0.0.1:18848/scrcpy?udid=%s&port=%d", udid, dev.H264LocalPort)
		}
	}
	port := dev.H264LocalPort
	m.mu.Unlock()

	if m.adb == nil {
		return nil
	}

	// 1. Find scrcpy-server.jar
	serverJarCandidates := []string{
		"C:/Program Files/HC BOX/resources/scrcpy/scrcpy-server.jar",
		"resources/scrcpy/scrcpy-server.jar",
		"scrcpy-server.jar",
	}
	var serverJar string
	for _, cand := range serverJarCandidates {
		if _, err := os.Stat(cand); err == nil {
			serverJar = cand
			break
		}
	}

	// Clean up stale scrcpy instances and port forward
	_, _ = m.adb.Shell(udid, "pkill -f com.genymobile.scrcpy.Server 2>/dev/null || true")
	_ = m.adb.RemoveForward(udid, port)

	if serverJar != "" {
		_ = m.adb.PushFile(udid, serverJar, "/data/local/tmp/scrcpy-server.jar")
	}

	// 2. Setup forward port
	_ = m.adb.ForwardPort(udid, port, "localabstract:scrcpy")

	// 3. Launch scrcpy-server in background with native resolution (max_size=0) to perfectly match touch coordinates
	go func() {
		args := []string{
			"-s", udid, "shell",
			"chmod 777 /data/local/tmp/scrcpy-server.jar; CLASSPATH=/data/local/tmp/scrcpy-server.jar app_process / com.genymobile.scrcpy.Server 1.19-ws7 info 0 8000000 60 -1 true - false true 0 false false - - false",
		}
		_, _ = m.adb.Run(args...)
	}()
	time.Sleep(800 * time.Millisecond)

	return nil
}

// ScanDevices performs an ADB scan and adds found devices to the registry
func (m *DeviceManager) ScanDevices() ([]*models.Device, error) {
	if m.adb == nil {
		return m.GetAllDevices(), nil
	}

	serials, err := m.adb.ListDevices()
	if err != nil {
		return m.GetAllDevices(), err
	}

	activeMap := make(map[string]bool)
	for _, s := range serials {
		activeMap[s] = true
	}

	// Update status of offline devices
	for _, dev := range m.GetAllDevices() {
		if !activeMap[dev.UDID] {
			if dev.UsbConnectStatus {
				dev.UsbConnectStatus = false
				dev.Status = "offline"
			}
		}
	}

	for _, serial := range serials {
		dev, exists := m.GetDevice(serial)
		if !exists {
			port := m.NextPort()
			model := "Android Device"
			if out, err := m.adb.Shell(serial, "getprop ro.product.model"); err == nil && strings.TrimSpace(out) != "" {
				model = strings.TrimSpace(out)
			}
			width := 1080
			height := 2220
			if out, err := m.adb.Shell(serial, "wm size"); err == nil {
				parts := strings.Split(out, ":")
				if len(parts) >= 2 {
					dim := strings.TrimSpace(parts[1])
					wh := strings.Split(dim, "x")
					if len(wh) == 2 {
						if w, err := strconv.Atoi(strings.TrimSpace(wh[0])); err == nil && w > 0 {
							width = w
						}
						if h, err := strconv.Atoi(strings.TrimSpace(wh[1])); err == nil && h > 0 {
							height = h
						}
					}
				}
			}

			// Align to multiple of 16 for H.264 hardware encoders
			width = width - (width % 16)
			height = height - (height % 16)

			dev = &models.Device{
				UDID:             serial,
				RealSerial:       serial,
				Name:             model,
				Model:            model,
				Platform:         "android",
				UsbConnectStatus: true,
				ScrcpyStatus:     true,
				ConnectType:      "USB",
				H264LocalPort:    port,
				StreamURL:        fmt.Sprintf("ws://127.0.0.1:18848/scrcpy?udid=%s&port=%d", serial, port),
				Width:            width,
				Height:           height,
				Group:            "",
				Status:           "online",
			}
			m.AddOrUpdate(dev)

			// Automatically start scrcpy for this device
			go m.StartScrcpy(serial)
		} else {
			if !dev.UsbConnectStatus {
				dev.UsbConnectStatus = true
				dev.Status = "online"
				go m.StartScrcpy(serial)
			}
		}
	}
	return m.GetAllDevices(), nil
}
