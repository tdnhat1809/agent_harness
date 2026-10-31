package workflow

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"hcbox/pkg/device"
	"hcbox/pkg/models"
)

func TestWorkflowSerialization(t *testing.T) {
	wf := &Workflow{
		ID:          "wf_test_01",
		Name:        "Auto Swipe TikTok",
		Description: "Automated TikTok feed scrolling",
		LoopCount:   3,
		TargetDevices: []string{"DEV_001", "DEV_002"},
		Nodes: []Node{
			{
				ID:    "node_1",
				Type:  NodeTypeLaunchApp,
				Label: "Open TikTok",
				Params: NodeParams{
					PackageName: "com.zhiliaoapp.musically",
				},
			},
			{
				ID:    "node_2",
				Type:  NodeTypeDelay,
				Label: "Wait 3s for splash",
				Params: NodeParams{
					DurationMs: 3000,
				},
			},
			{
				ID:    "node_3",
				Type:  NodeTypeTap,
				Label: "Tap Center",
				Params: NodeParams{
					X: 0.5,
					Y: 0.5,
				},
			},
			{
				ID:    "node_4",
				Type:  NodeTypeSwipe,
				Label: "Swipe Up",
				Params: NodeParams{
					Direction:  "up",
					DurationMs: 250,
				},
			},
			{
				ID:    "node_5",
				Type:  NodeTypeKey,
				Label: "Press Home",
				Params: NodeParams{
					KeyCode: 3, // Android Keycode HOME
				},
			},
		},
	}

	data, err := json.Marshal(wf)
	if err != nil {
		t.Fatalf("failed to marshal workflow: %v", err)
	}

	var decoded Workflow
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal workflow: %v", err)
	}

	if decoded.ID != wf.ID || len(decoded.Nodes) != 5 {
		t.Fatalf("decoded workflow mismatch: id=%s, nodes=%d", decoded.ID, len(decoded.Nodes))
	}
	if decoded.Nodes[0].Type != NodeTypeLaunchApp {
		t.Fatalf("expected node 0 to be launch_app, got %s", decoded.Nodes[0].Type)
	}
}

func TestWorkflowExecution(t *testing.T) {
	devMgr := device.NewDeviceManager(nil)
	devMgr.AddOrUpdate(&models.Device{
		UDID:   "TEST_DEV",
		Width:  1080,
		Height: 2220,
		Status: "online",
	})

	engine := NewEngine(devMgr)

	wf := &Workflow{
		ID:            "wf_exec_test",
		Name:          "Quick Flow",
		LoopCount:     1,
		TargetDevices: []string{"TEST_DEV"},
		Nodes: []Node{
			{
				ID:    "step_1",
				Type:  NodeTypeTap,
				Label: "Tap",
				Params: NodeParams{
					X: 0.5,
					Y: 0.5,
				},
			},
			{
				ID:    "step_2",
				Type:  NodeTypeDelay,
				Label: "Short Sleep",
				Params: NodeParams{
					DurationMs: 20,
				},
			},
			{
				ID:    "step_3",
				Type:  NodeTypeTypeText,
				Label: "Type Hello",
				Params: NodeParams{
					Text: "Hello Automation",
				},
			},
		},
	}

	var logs []string
	ctx := context.Background()
	err := engine.Execute(ctx, wf, func(logMsg string) {
		logs = append(logs, logMsg)
	})

	if err != nil {
		t.Fatalf("workflow execution failed: %v", err)
	}

	if len(logs) == 0 {
		t.Fatalf("expected execution logs, got none")
	}

	status := engine.GetStatus()
	if status.IsRunning {
		t.Fatalf("expected engine to be idle after execution")
	}
}

func TestWorkflowCancellation(t *testing.T) {
	devMgr := device.NewDeviceManager(nil)
	devMgr.AddOrUpdate(&models.Device{
		UDID:   "TEST_DEV_CANCEL",
		Status: "online",
	})

	engine := NewEngine(devMgr)

	wf := &Workflow{
		ID:            "wf_long_delay",
		Name:          "Long Flow",
		LoopCount:     10,
		TargetDevices: []string{"TEST_DEV_CANCEL"},
		Nodes: []Node{
			{
				ID:    "step_long",
				Type:  NodeTypeDelay,
				Label: "Long Sleep",
				Params: NodeParams{
					DurationMs: 5000,
				},
			},
		},
	}

	ctx, cancel := context.WithCancel(context.Background())

	doneChan := make(chan error, 1)
	go func() {
		err := engine.Execute(ctx, wf, nil)
		doneChan <- err
	}()

	time.Sleep(50 * time.Millisecond)
	cancel() // Cancel early

	select {
	case err := <-doneChan:
		if err == nil {
			t.Fatalf("expected context cancellation error, got nil")
		}
	case <-time.After(1 * time.Second):
		t.Fatalf("timed out waiting for workflow to cancel")
	}
}

func TestWorkflowNodeValidation(t *testing.T) {
	tests := []struct {
		node    Node
		isValid bool
	}{
		{
			node:    Node{ID: "n1", Type: NodeTypeTap, Params: NodeParams{X: 0.5, Y: 0.5}},
			isValid: true,
		},
		{
			node:    Node{ID: "n2", Type: NodeTypeSwipe, Params: NodeParams{Direction: "up"}},
			isValid: true,
		},
		{
			node:    Node{ID: "n3", Type: NodeTypeLaunchApp, Params: NodeParams{PackageName: "com.test.app"}},
			isValid: true,
		},
		{
			node:    Node{ID: "n4", Type: NodeTypeLaunchApp, Params: NodeParams{PackageName: ""}},
			isValid: false,
		},
		{
			node:    Node{ID: "n5", Type: NodeTypeTypeText, Params: NodeParams{Text: ""}},
			isValid: false,
		},
	}

	for i, tt := range tests {
		err := ValidateNode(tt.node)
		if tt.isValid && err != nil {
			t.Errorf("test %d: expected valid node, got error: %v", i, err)
		}
		if !tt.isValid && err == nil {
			t.Errorf("test %d: expected invalid node, got nil error", i)
		}
	}
}
