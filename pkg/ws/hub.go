package ws

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/websocket"

	"hcbox/pkg/device"
	"hcbox/pkg/models"
	"hcbox/pkg/scrcpy"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all frontend origins
	},
	ReadBufferSize:  1024 * 64,
	WriteBufferSize: 1024 * 64,
}

// Hub manages active WebSocket client connections and event broadcasting
type Hub struct {
	mu          sync.RWMutex
	clients     map[*Client]bool
	deviceMgr   *device.DeviceManager
	syncControl bool
	addr        string
	server      *http.Server
	listener    net.Listener
}

// Client wraps an active WebSocket connection
type Client struct {
	hub  *Hub
	conn *websocket.Conn
	send chan []byte
}

// NewHub creates a new WebSocket Hub
func NewHub(deviceMgr *device.DeviceManager, addr string) *Hub {
	if addr == "" {
		addr = ":28848"
	}
	return &Hub{
		clients:     make(map[*Client]bool),
		deviceMgr:   deviceMgr,
		syncControl: true,
		addr:        addr,
	}
}

// Handler returns the http.Handler for the WebSocket hub
func (h *Hub) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/ws", h.HandleWebSocket)
	return mux
}

// Start begins listening on the WebSocket port with automatic fallback if blocked by OS
func (h *Hub) Start() error {
	var ln net.Listener
	var err error

	// Try designated address first
	ln, err = net.Listen("tcp", h.addr)
	if err != nil {
		// If port is blocked by Windows hyper-v exclusion, try fallbacks
		fallbackPorts := []string{":29848", ":20848", ":38848"}
		for _, fb := range fallbackPorts {
			log.Printf("[!] Port %s unavailable (%v), attempting fallback port %s...", h.addr, err, fb)
			if fbLn, fbErr := net.Listen("tcp", fb); fbErr == nil {
				ln = fbLn
				h.addr = fb
				err = nil
				break
			}
		}
	}

	if err != nil {
		return fmt.Errorf("failed to bind WebSocket Hub listener: %v", err)
	}

	h.listener = ln
	h.server = &http.Server{
		Handler: h.Handler(),
	}

	log.Printf("[+] WebSocket Control Hub active on ws://127.0.0.1%s/ws", h.addr)
	return h.server.Serve(ln)
}

// Close terminates the hub server
func (h *Hub) Close() error {
	h.mu.Lock()
	for client := range h.clients {
		_ = client.conn.Close()
		close(client.send)
		delete(h.clients, client)
	}
	h.mu.Unlock()

	if h.listener != nil {
		_ = h.listener.Close()
	}
	if h.server != nil {
		return h.server.Close()
	}
	return nil
}

// FormatDevicesForFrontend maps device list to key-value objects expected by Vue Pinia store
func FormatDevicesForFrontend(devices []*models.Device) []map[string]any {
	result := make([]map[string]any, 0, len(devices))
	for _, dev := range devices {
		result = append(result, map[string]any{
			"key":   dev.UDID,
			"value": dev,
		})
	}
	return result
}

// BroadcastDevices sends properly formatted device list to all connected clients
func (h *Hub) BroadcastDevices() {
	devices := h.deviceMgr.GetAllDevices()
	h.BroadcastEvent("update-connected-devices", FormatDevicesForFrontend(devices))
}

// Broadcast sends raw bytes to all connected clients
func (h *Hub) Broadcast(msg []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	for client := range h.clients {
		select {
		case client.send <- msg:
		default:
			// If buffer full, drop or ignore
		}
	}
}

// BroadcastEvent sends a structured event to all frontend clients
func (h *Hub) BroadcastEvent(command string, data any) {
	evt := models.WsOutMessage{
		Type:    "event",
		Command: command,
		Data:    data,
	}
	bytes, err := json.Marshal(evt)
	if err == nil {
		h.Broadcast(bytes)
	}
}

// HandleWebSocket upgrades incoming HTTP connections to WebSocket
func (h *Hub) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("WebSocket upgrade error:", err)
		return
	}

	client := &Client{
		hub:  h,
		conn: conn,
		send: make(chan []byte, 256),
	}

	h.mu.Lock()
	h.clients[client] = true
	h.mu.Unlock()

	// Send auth confirmation immediately
	authResp := models.WsOutMessage{
		Action:     "auth",
		StatusCode: 200,
		Code:       0,
		SessionId:  "session_pro_master_100",
		Message:    "WebSocket authenticated successfully",
	}
	if b, err := json.Marshal(authResp); err == nil {
		_ = client.conn.WriteMessage(websocket.TextMessage, b)
	}

	go client.writePump()
	go client.readPump()
}

func (c *Client) readPump() {
	defer func() {
		c.hub.mu.Lock()
		if _, ok := c.hub.clients[c]; ok {
			delete(c.hub.clients, c)
			close(c.send)
		}
		c.hub.mu.Unlock()
		_ = c.conn.Close()
	}()

	c.conn.SetReadLimit(1024 * 1024)

	for {
		messageType, message, err := c.conn.ReadMessage()
		if err != nil {
			break
		}

		if messageType == websocket.TextMessage {
			text := string(message)
			if text == "ping" {
				c.send <- []byte("pong")
				continue
			}

			var in models.WsInMessage
			if err := json.Unmarshal(message, &in); err != nil {
				continue
			}

			c.hub.processMessage(c, in)
		}
	}
}

func (c *Client) writePump() {
	ticker := time.NewTicker(30 * time.Second)
	defer func() {
		ticker.Stop()
		_ = c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			if !ok {
				_ = c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				return
			}
		case <-ticker.C:
			// Heartbeat keep-alive ping
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// processMessage routes commands from frontend UI to target devices
func (h *Hub) processMessage(client *Client, msg models.WsInMessage) {
	// If it's a request with requestId, acknowledge it
	if msg.RequestId > 0 {
		resp := models.WsOutMessage{
			RequestId: msg.RequestId,
			Code:      0,
			Message:   "ok",
		}
		if b, err := json.Marshal(resp); err == nil {
			client.send <- b
		}
	}

	cmd := msg.Command
	if cmd == "" && msg.Action != "" {
		cmd = msg.Action
	}

	switch cmd {
	case "intConfig":
		resp := models.WsOutMessage{
			Type:    "event",
			Command: "init-config",
			Data: map[string]any{
				"sync_control":    h.syncControl,
				"max_connections": 100,
			},
		}
		if b, err := json.Marshal(resp); err == nil {
			client.send <- b
		}

	case "frontendReady", "getDevicesInfo":
		devices := h.deviceMgr.GetAllDevices()
		resp := models.WsOutMessage{
			Type:    "event",
			Command: "update-connected-devices",
			Data:    FormatDevicesForFrontend(devices),
		}
		if b, err := json.Marshal(resp); err == nil {
			client.send <- b
		}

	case "connect":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.StartScrcpy(udid)
		}
		time.Sleep(200 * time.Millisecond)
		h.BroadcastDevices()

	case "saveConfig":
		var conf struct {
			SyncControl bool `json:"sync_control"`
		}
		if len(msg.Data) > 0 {
			if err := json.Unmarshal(msg.Data, &conf); err == nil {
				h.syncControl = conf.SyncControl
			}
		}

	case "touchDown":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectTouch(udid, scrcpy.MotionEventActionDown, msg.Point)
		}

	case "touchMove":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectTouch(udid, scrcpy.MotionEventActionMove, msg.Point)
		}

	case "touchUp":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectTouch(udid, scrcpy.MotionEventActionUp, msg.Point)
		}

	case "swipeAlongPath":
		path := msg.Path
		if len(path) == 0 {
			path = msg.SwipePath
		}
		if len(path) >= 2 {
			for _, udid := range msg.Devices {
				p0 := path[0]
				pEnd := path[len(path)-1]
				go func(u string, start, end []float64) {
					_ = h.deviceMgr.Swipe(u, start[0], start[1], end[0], end[1], 200)
				}(udid, p0, pEnd)
			}
		}

	case "swipeUp":
		for _, udid := range msg.Devices {
			go h.deviceMgr.Swipe(udid, 0.5, 0.75, 0.5, 0.25, 200)
		}

	case "swipeDown":
		for _, udid := range msg.Devices {
			go h.deviceMgr.Swipe(udid, 0.5, 0.25, 0.5, 0.75, 200)
		}

	case "swipeLeft":
		for _, udid := range msg.Devices {
			go h.deviceMgr.Swipe(udid, 0.8, 0.5, 0.2, 0.5, 200)
		}

	case "swipeRight":
		for _, udid := range msg.Devices {
			go h.deviceMgr.Swipe(udid, 0.2, 0.5, 0.8, 0.5, 200)
		}

	case "lock":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodePower)
		}

	case "unlock":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodePower)
			time.Sleep(100 * time.Millisecond)
			go h.deviceMgr.Swipe(udid, 0.5, 0.8, 0.5, 0.3, 150)
		}

	case "home":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodeHome)
		}

	case "back":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodeBack)
		}

	case "appSwitch":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodeAppSwitch)
		}

	case "volumeUp":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodeVolumeUp)
		}

	case "volumeDown":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodeVolumeDown)
		}

	case "sendEnterKey":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodeEnter)
		}

	case "sendDeleteKey":
		for _, udid := range msg.Devices {
			_ = h.deviceMgr.InjectKeycode(udid, scrcpy.KeycodeDel)
		}

	case "sendKeys":
		text := msg.Text
		if text == "" {
			text = msg.Keys
		}
		if text != "" {
			for _, udid := range msg.Devices {
				_ = h.deviceMgr.InjectText(udid, text)
			}
		}
	}
}
