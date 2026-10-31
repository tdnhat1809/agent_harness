package models

import "encoding/json"

// Device represents a connected Android or iOS device in the farm
type Device struct {
	UDID              string `json:"udid"`
	Name              string `json:"name"`
	Model             string `json:"model"`
	Platform          string `json:"platform"` // "android" or "ios"
	UsbConnectStatus  bool   `json:"usb_connect_status"`
	ScrcpyStatus      bool   `json:"scrcpy_status"`
	ConnectType       string `json:"connect_type"`
	RealSerial        string `json:"real_serial"`
	H264LocalPort     int    `json:"h264_local_port"`
	H264WebSocketPort int    `json:"h264_websocket_port,omitempty"`
	StreamURL         string `json:"stream_url"`
	Width             int    `json:"width"`
	Height            int    `json:"height"`
	Group             string `json:"group"`
	Status            string `json:"status"` // "online" or "offline"
	WindowState       string `json:"windowState,omitempty"`
}

// UserInfo represents the current session user details & license level
type UserInfo struct {
	UserId         int    `json:"userId"`
	UserName       string `json:"userName"`
	CurrentPlan    string `json:"currentPlan"`
	MaxConnections int    `json:"maxConnections"`
	CanConnect     bool   `json:"canConnect"`
	WsapiEnabled   bool   `json:"wsapiEnabled"`
	DeviceCount    int    `json:"deviceCount"`
	ExpiryDate     string `json:"expiryDate"`
	Role           string `json:"role"`
}

// ApiResponse represents the standard JSON API response structure
type ApiResponse struct {
	Code int    `json:"code"`
	Msg  string `json:"msg"`
	Data any    `json:"data"`
}

// VersionInfo represents the version-check response structure
type VersionInfo struct {
	Checked        bool   `json:"checked"`
	CurrentVersion string `json:"currentVersion"`
	ForceUpdate    bool   `json:"forceUpdate"`
	Message        string `json:"message"`
	NewVersion     string `json:"newVersion"`
	Reason         string `json:"reason"`
	UpdateType     string `json:"updateType"`
	UpdateUrl      string `json:"updateUrl"`
}

// MenuItem represents frontend navigation menu items
type MenuItem struct {
	Name      string      `json:"name"`
	Path      string      `json:"path"`
	Component string      `json:"component"`
	Meta      MenuMeta    `json:"meta"`
	Children  []*MenuItem `json:"children,omitempty"`
}

// MenuMeta represents metadata for a menu route
type MenuMeta struct {
	Title     string   `json:"title"`
	Icon      string   `json:"icon,omitempty"`
	Roles     []string `json:"roles"`
	KeepAlive bool     `json:"keepAlive"`
	FixedTab  bool     `json:"fixedTab,omitempty"`
}

// WsInMessage represents incoming WebSocket payloads from the frontend
type WsInMessage struct {
	Command   string          `json:"command,omitempty"`
	Action    string          `json:"action,omitempty"`
	Type      string          `json:"type,omitempty"`
	Id        int             `json:"id,omitempty"`
	RequestId int             `json:"requestId,omitempty"`
	Devices   []string        `json:"devices,omitempty"`
	Point     []float64       `json:"point,omitempty"` // [x, y]
	Path      [][]float64     `json:"path,omitempty"`
	SwipePath [][]float64     `json:"swipePath,omitempty"`
	Keys      string          `json:"keys,omitempty"`
	Text      string          `json:"text,omitempty"`
	Data      json.RawMessage `json:"data,omitempty"`
	Comm      json.RawMessage `json:"comm,omitempty"`
}

// WsOutMessage represents outgoing WebSocket events and command responses
type WsOutMessage struct {
	Type       string `json:"type,omitempty"`
	Command    string `json:"command,omitempty"`
	Action     string `json:"action,omitempty"`
	Code       int    `json:"code,omitempty"`
	StatusCode int    `json:"StatusCode,omitempty"`
	Message    string `json:"message,omitempty"`
	SessionId  string `json:"sessionId,omitempty"`
	Id         int    `json:"id,omitempty"`
	RequestId  int    `json:"requestId,omitempty"`
	Data       any    `json:"data,omitempty"`
}
