package api

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"hcbox/pkg/device"
	"hcbox/pkg/models"
	"hcbox/pkg/workflow"
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

func TestWorkflowMenuSimple(t *testing.T) {
	server, _ := setupTestServer()
	req, _ := http.NewRequest("GET", "/api/v3/system/menus/simple", nil)
	w := httptest.NewRecorder()
	server.Router().ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected status 200, got %d", w.Code)
	}

	var resp struct {
		Code int                `json:"code"`
		Data []*models.MenuItem `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to parse json: %v", err)
	}

	// Verify Workflow menu item is present with isIframe: true
	var foundWorkflow bool
	for _, menu := range resp.Data {
		if menu.Path == "/workflow" {
			foundWorkflow = true
			if !menu.Meta.IsIframe {
				t.Fatalf("expected Workflow menu to have isIframe=true")
			}
			if menu.Meta.Link == "" {
				t.Fatalf("expected Workflow menu to have non-empty link")
			}
		}
	}

	if !foundWorkflow {
		t.Fatalf("Workflow menu item not found in simple menus")
	}
}

func TestWorkflowEndpoints(t *testing.T) {
	server, _ := setupTestServer()

	// 1. Test GET /api/workflow/templates
	reqTpl, _ := http.NewRequest("GET", "/api/workflow/templates", nil)
	wTpl := httptest.NewRecorder()
	server.Router().ServeHTTP(wTpl, reqTpl)

	if wTpl.Code != http.StatusOK {
		t.Fatalf("expected templates status 200, got %d", wTpl.Code)
	}

	// 2. Test GET /api/workflow/status
	reqStatus, _ := http.NewRequest("GET", "/api/workflow/status", nil)
	wStatus := httptest.NewRecorder()
	server.Router().ServeHTTP(wStatus, reqStatus)

	if wStatus.Code != http.StatusOK {
		t.Fatalf("expected status 200, got %d", wStatus.Code)
	}
}

func TestWorkflowRunAndStop(t *testing.T) {
	server, _ := setupTestServer()

	wf := workflow.Workflow{
		ID:        "test_run_1",
		Name:      "Test Workflow",
		LoopCount: 1,
		Nodes: []workflow.Node{
			{
				ID:    "step1",
				Type:  workflow.NodeTypeDelay,
				Label: "Wait",
				Params: workflow.NodeParams{
					DurationMs: 100,
				},
			},
		},
	}
	body, _ := json.Marshal(wf)
	reqRun, _ := http.NewRequest("POST", "/api/workflow/run", bytes.NewReader(body))
	reqRun.Header.Set("Content-Type", "application/json")
	wRun := httptest.NewRecorder()
	server.Router().ServeHTTP(wRun, reqRun)

	if wRun.Code != http.StatusOK {
		t.Fatalf("expected run status 200, got %d", wRun.Code)
	}

	// Stop workflow
	reqStop, _ := http.NewRequest("POST", "/api/workflow/stop", nil)
	wStop := httptest.NewRecorder()
	server.Router().ServeHTTP(wStop, reqStop)

	if wStop.Code != http.StatusOK {
		t.Fatalf("expected stop status 200, got %d", wStop.Code)
	}

	// Logs
	reqLogs, _ := http.NewRequest("GET", "/api/workflow/logs", nil)
	wLogs := httptest.NewRecorder()
	server.Router().ServeHTTP(wLogs, reqLogs)

	if wLogs.Code != http.StatusOK {
		t.Fatalf("expected logs status 200, got %d", wLogs.Code)
	}

	// Workflow builder HTML endpoint
	reqBuilder, _ := http.NewRequest("GET", "/workflow-builder", nil)
	wBuilder := httptest.NewRecorder()
	server.Router().ServeHTTP(wBuilder, reqBuilder)

	if wBuilder.Code != http.StatusOK {
		t.Fatalf("expected workflow builder status 200, got %d", wBuilder.Code)
	}
}


