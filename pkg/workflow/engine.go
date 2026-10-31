package workflow

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"strings"
	"sync"
	"time"

	"hcbox/pkg/device"
	"hcbox/pkg/scrcpy"
)

// Engine orchestrates and executes workflows across connected target devices
type Engine struct {
	mu           sync.RWMutex
	deviceMgr    *device.DeviceManager
	cancelFunc   context.CancelFunc
	status       EngineStatus
	activeWf     *Workflow
	logCallbacks []func(string)
}

// NewEngine creates a new workflow automation engine
func NewEngine(deviceMgr *device.DeviceManager) *Engine {
	return &Engine{
		deviceMgr: deviceMgr,
	}
}

// GetStatus returns the current runtime execution status
func (e *Engine) GetStatus() EngineStatus {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.status
}

// Stop cancels the currently running workflow
func (e *Engine) Stop() {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.cancelFunc != nil {
		e.cancelFunc()
		e.cancelFunc = nil
	}
	e.status.IsRunning = false
	e.status.ErrorMessage = "Stopped by user"
}

// Execute runs a workflow synchronously or until ctx is cancelled
func (e *Engine) Execute(ctx context.Context, wf *Workflow, onLog func(msg string)) error {
	if wf == nil || len(wf.Nodes) == 0 {
		return fmt.Errorf("workflow is empty or nil")
	}

	execCtx, cancel := context.WithCancel(ctx)
	e.mu.Lock()
	e.cancelFunc = cancel
	e.activeWf = wf
	totalLoops := wf.LoopCount
	if totalLoops <= 0 {
		totalLoops = 1
	}
	e.status = EngineStatus{
		IsRunning:    true,
		WorkflowID:   wf.ID,
		WorkflowName: wf.Name,
		TotalSteps:   len(wf.Nodes),
		TotalLoops:   totalLoops,
	}
	e.mu.Unlock()

	defer func() {
		e.mu.Lock()
		e.status.IsRunning = false
		e.cancelFunc = nil
		e.mu.Unlock()
		cancel()
	}()

	logger := func(format string, args ...any) {
		msg := fmt.Sprintf(format, args...)
		log.Printf("[Workflow] %s", msg)
		if onLog != nil {
			onLog(msg)
		}
	}

	logger("Starting workflow %q (ID: %s, %d steps, %d loops)", wf.Name, wf.ID, len(wf.Nodes), totalLoops)

	targetUDIDs := e.resolveTargetDevices(wf.TargetDevices)
	if len(targetUDIDs) == 0 {
		logger("Warning: No online target devices found. Running in simulation mode.")
	} else {
		logger("Target devices (%d): %v", len(targetUDIDs), targetUDIDs)
	}

	// Execution loop
	loopCount := 0
	for {
		loopCount++
		if wf.LoopCount > 0 && loopCount > wf.LoopCount {
			break
		}

		e.mu.Lock()
		e.status.CurrentLoop = loopCount
		e.mu.Unlock()

		logger("--- Beginning Loop #%d ---", loopCount)

		for stepIdx, node := range wf.Nodes {
			select {
			case <-execCtx.Done():
				logger("Workflow cancelled during step %d", stepIdx+1)
				return execCtx.Err()
			default:
			}

			if node.Disabled {
				logger("[Step %d/%d] Skipping disabled node: %s", stepIdx+1, len(wf.Nodes), node.Label)
				continue
			}

			if err := ValidateNode(node); err != nil {
				errMsg := fmt.Sprintf("[Step %d/%d] Invalid node %s: %v", stepIdx+1, len(wf.Nodes), node.ID, err)
				logger("%s", errMsg)
				return fmt.Errorf("%s", errMsg)
			}

			e.mu.Lock()
			e.status.CurrentStep = stepIdx + 1
			e.status.CurrentNodeID = node.ID
			e.mu.Unlock()

			logger("[Step %d/%d] Executing [%s] %s", stepIdx+1, len(wf.Nodes), node.Type, node.Label)

			if err := e.executeNode(execCtx, node, targetUDIDs, logger); err != nil {
				errMsg := fmt.Sprintf("Error executing step %s (%s): %v", node.ID, node.Label, err)
				logger("%s", errMsg)
				e.mu.Lock()
				e.status.ErrorMessage = errMsg
				e.mu.Unlock()
				return err
			}
		}

		// Loop delay if configured
		if wf.LoopDelayMs > 0 && (wf.LoopCount <= 0 || loopCount < wf.LoopCount) {
			select {
			case <-execCtx.Done():
				return execCtx.Err()
			case <-time.After(time.Duration(wf.LoopDelayMs) * time.Millisecond):
			}
		}
	}

	logger("Workflow %q completed successfully (%d loops)", wf.Name, loopCount)
	return nil
}

func (e *Engine) resolveTargetDevices(specified []string) []string {
	if len(specified) > 0 {
		return specified
	}
	if e.deviceMgr == nil {
		return nil
	}
	var res []string
	for _, dev := range e.deviceMgr.GetAllDevices() {
		if dev.Status == "online" || dev.UsbConnectStatus {
			res = append(res, dev.UDID)
		}
	}
	return res
}

func (e *Engine) executeNode(ctx context.Context, node Node, targetUDIDs []string, logger func(string, ...any)) error {
	switch node.Type {
	case NodeTypeTap:
		x := node.Params.X
		y := node.Params.Y
		if node.Params.RandomJitter {
			jitter := (rand.Float64() - 0.5) * 0.02 // +/- 1%
			x += jitter
			y += jitter
		}
		for _, udid := range targetUDIDs {
			if e.deviceMgr != nil {
				_ = e.deviceMgr.InjectTouch(udid, scrcpy.MotionEventActionDown, []float64{x, y})
				time.Sleep(50 * time.Millisecond)
				_ = e.deviceMgr.InjectTouch(udid, scrcpy.MotionEventActionUp, []float64{x, y})
			}
		}

	case NodeTypeSwipe:
		var x1, y1, x2, y2 float64
		switch strings.ToLower(node.Params.Direction) {
		case "down":
			x1, y1, x2, y2 = 0.5, 0.25, 0.5, 0.75
		case "left":
			x1, y1, x2, y2 = 0.8, 0.5, 0.2, 0.5
		case "right":
			x1, y1, x2, y2 = 0.2, 0.5, 0.8, 0.5
		case "custom":
			x1, y1, x2, y2 = node.Params.X, node.Params.Y, node.Params.X2, node.Params.Y2
		default: // "up"
			x1, y1, x2, y2 = 0.5, 0.75, 0.5, 0.25
		}
		duration := node.Params.DurationMs
		if duration <= 0 {
			duration = 200
		}
		for _, udid := range targetUDIDs {
			if e.deviceMgr != nil {
				_ = e.deviceMgr.Swipe(udid, x1, y1, x2, y2, duration)
			}
		}

	case NodeTypeTypeText:
		for _, udid := range targetUDIDs {
			if e.deviceMgr != nil {
				_ = e.deviceMgr.InjectText(udid, node.Params.Text)
			}
		}

	case NodeTypeKey:
		keyCode := node.Params.KeyCode
		if keyCode == 0 {
			switch strings.ToLower(node.Params.KeyAction) {
			case "home":
				keyCode = scrcpy.KeycodeHome
			case "back":
				keyCode = scrcpy.KeycodeBack
			case "app_switch", "apps":
				keyCode = scrcpy.KeycodeAppSwitch
			case "power", "lock":
				keyCode = scrcpy.KeycodePower
			case "volume_up":
				keyCode = scrcpy.KeycodeVolumeUp
			case "volume_down":
				keyCode = scrcpy.KeycodeVolumeDown
			case "enter":
				keyCode = scrcpy.KeycodeEnter
			case "del", "delete":
				keyCode = scrcpy.KeycodeDel
			default:
				keyCode = scrcpy.KeycodeHome
			}
		}
		for _, udid := range targetUDIDs {
			if e.deviceMgr != nil {
				_ = e.deviceMgr.InjectKeycode(udid, keyCode)
			}
		}

	case NodeTypeDelay:
		delayMs := node.Params.DurationMs
		if node.Params.MinDelayMs > 0 && node.Params.MaxDelayMs > node.Params.MinDelayMs {
			delta := node.Params.MaxDelayMs - node.Params.MinDelayMs
			delayMs = node.Params.MinDelayMs + rand.Intn(delta)
		}
		if delayMs > 0 {
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(time.Duration(delayMs) * time.Millisecond):
			}
		}

	case NodeTypeLaunchApp:
		for _, udid := range targetUDIDs {
			if e.deviceMgr != nil {
				_ = e.deviceMgr.LaunchApp(udid, node.Params.PackageName)
			}
		}

	case NodeTypeStopApp:
		for _, udid := range targetUDIDs {
			if e.deviceMgr != nil {
				_ = e.deviceMgr.StopApp(udid, node.Params.PackageName)
			}
		}

	case NodeTypeShell:
		for _, udid := range targetUDIDs {
			if e.deviceMgr != nil {
				out, err := e.deviceMgr.RunShell(udid, node.Params.ShellCmd)
				if err != nil {
					logger("[%s] shell error: %v", udid, err)
				} else if out != "" {
					logger("[%s] shell output: %s", udid, strings.TrimSpace(out))
				}
			}
		}
	}

	return nil
}

// GetPredefinedTemplates returns ready-to-use phone automation workflows
func GetPredefinedTemplates() []*Workflow {
	return []*Workflow{
		{
			ID:          "tpl_tiktok_scroll",
			Name:        "Auto Lướt TikTok / Video Ngắn",
			Description: "Tự động mở TikTok, chờ xem video 3-7 giây ngẫu nhiên và vuốt lên xem video tiếp theo",
			LoopCount:   10,
			LoopDelayMs: 500,
			Nodes: []Node{
				{
					ID:    "open_app",
					Type:  NodeTypeLaunchApp,
					Label: "Mở Ứng Dụng TikTok",
					Params: NodeParams{
						PackageName: "com.zhiliaoapp.musically",
					},
				},
				{
					ID:    "wait_load",
					Type:  NodeTypeDelay,
					Label: "Chờ Tải Ứng Dụng",
					Params: NodeParams{
						DurationMs: 4000,
					},
				},
				{
					ID:    "random_watch",
					Type:  NodeTypeDelay,
					Label: "Xem Video (3 - 6 Giây Ngẫu Nhiên)",
					Params: NodeParams{
						MinDelayMs: 3000,
						MaxDelayMs: 6000,
					},
				},
				{
					ID:    "swipe_next",
					Type:  NodeTypeSwipe,
					Label: "Vuốt Lên Sang Video Kế",
					Params: NodeParams{
						Direction:  "up",
						DurationMs: 250,
					},
				},
			},
		},
		{
			ID:          "tpl_chrome_browse",
			Name:        "Auto Mở Trình Duyệt & Tìm Kiếm",
			Description: "Mở Chrome, chạm thanh tìm kiếm, gõ từ khóa và nhấn Enter",
			LoopCount:   1,
			Nodes: []Node{
				{
					ID:    "open_chrome",
					Type:  NodeTypeLaunchApp,
					Label: "Mở Google Chrome",
					Params: NodeParams{
						PackageName: "com.android.chrome",
					},
				},
				{
					ID:    "wait_chrome",
					Type:  NodeTypeDelay,
					Label: "Chờ Trình Duyệt Sẵn Sàng",
					Params: NodeParams{
						DurationMs: 2500,
					},
				},
				{
					ID:    "tap_url_bar",
					Type:  NodeTypeTap,
					Label: "Chạm Thanh Địa Chỉ URL",
					Params: NodeParams{
						X: 0.5,
						Y: 0.12,
					},
				},
				{
					ID:    "type_search",
					Type:  NodeTypeTypeText,
					Label: "Gõ Từ Khóa",
					Params: NodeParams{
						Text: "news.google.com",
					},
				},
				{
					ID:    "press_enter",
					Type:  NodeTypeKey,
					Label: "Nhấn Phím Enter",
					Params: NodeParams{
						KeyAction: "enter",
					},
				},
			},
		},
		{
			ID:          "tpl_device_wake_clean",
			Name:        "Đánh Thức Thiết Bị & Dọn Dẹp",
			Description: "Bật màn hình, vuốt mở khóa, về màn hình chính và xóa cache đa nhiệm",
			LoopCount:   1,
			Nodes: []Node{
				{
					ID:    "wake_screen",
					Type:  NodeTypeKey,
					Label: "Bật Nguồn Màn Hình",
					Params: NodeParams{
						KeyAction: "power",
					},
				},
				{
					ID:    "delay_wake",
					Type:  NodeTypeDelay,
					Label: "Chờ Màn Hình Sáng",
					Params: NodeParams{
						DurationMs: 500,
					},
				},
				{
					ID:    "swipe_unlock",
					Type:  NodeTypeSwipe,
					Label: "Vuốt Mở Khóa Màn Hình",
					Params: NodeParams{
						Direction:  "up",
						DurationMs: 200,
					},
				},
				{
					ID:    "press_home",
					Type:  NodeTypeKey,
					Label: "Về Màn Hình Chính (Home)",
					Params: NodeParams{
						KeyAction: "home",
					},
				},
			},
		},
	}
}
