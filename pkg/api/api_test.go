package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"hcbox/pkg/device"
	"hcbox/pkg/models"
)

func setupTestServer() (*Server, *device.DeviceManager) {
	devMgr := device.NewDeviceManager(nil)
	server := NewServer(devMgr, ":20080")
	return server, devMgr
}

func TestVersionCheck(t *testing.T) {
	server, _ := setupTestServer()
	req, _ := http.NewRequest("GET", "/api/auth/version-check", nil)
	w := httptest.NewRecorder()
	server.Router().ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected status 200, got %d", w.Code)
	}

	var resp struct {
		Code int                `json:"code"`
		Data models.VersionInfo `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to parse json: %v", err)
	}
	if resp.Code != 200 || !resp.Data.Checked || resp.Data.CurrentVersion != "1.0.9" {
		t.Fatalf("unexpected version data: %+v", resp)
	}
}

func TestUserInfoBypass(t *testing.T) {
	server, _ := setupTestServer()
	req, _ := http.NewRequest("GET", "/api/user/info", nil)
	w := httptest.NewRecorder()
	server.Router().ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected status 200, got %d", w.Code)
	}

	var resp struct {
		Code int             `json:"code"`
		Data models.UserInfo `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to parse json: %v", err)
	}

	// Verify Pro plan, 100 maxConnections, canConnect true
	if resp.Data.CurrentPlan != "pro" {
		t.Fatalf("expected currentPlan pro, got %s", resp.Data.CurrentPlan)
	}
	if resp.Data.MaxConnections != 100 {
		t.Fatalf("expected maxConnections 100, got %d", resp.Data.MaxConnections)
	}
	if !resp.Data.CanConnect || !resp.Data.WsapiEnabled {
		t.Fatalf("expected canConnect and wsapiEnabled true")
	}
}

func TestLogin(t *testing.T) {
	server, _ := setupTestServer()
	req, _ := http.NewRequest("POST", "/api/auth/login", nil)
	w := httptest.NewRecorder()
	server.Router().ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected status 200, got %d", w.Code)
	}

	var resp struct {
		Code int `json:"code"`
		Data struct {
			Token       string `json:"token"`
			AccessToken string `json:"accessToken"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to parse json: %v", err)
	}
	if resp.Data.Token == "" || resp.Data.AccessToken == "" {
		t.Fatalf("expected non-empty tokens")
	}
}

func TestDeviceList(t *testing.T) {
	server, devMgr := setupTestServer()
	devMgr.AddOrUpdate(&models.Device{
		UDID:             "TEST_DEVICE",
		Name:             "Phone A",
		UsbConnectStatus: true,
	})

	req, _ := http.NewRequest("GET", "/device/list", nil)
	w := httptest.NewRecorder()
	server.Router().ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected status 200, got %d", w.Code)
	}

	var resp struct {
		Code int              `json:"code"`
		Data []*models.Device `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to parse json: %v", err)
	}
	if len(resp.Data) != 1 || resp.Data[0].UDID != "TEST_DEVICE" {
		t.Fatalf("expected device TEST_DEVICE in response")
	}
}
