package workflow

import (
	"errors"
	"strings"
)

// Supported node types for phone automation workflow
const (
	NodeTypeTap       = "tap"
	NodeTypeSwipe     = "swipe"
	NodeTypeTypeText  = "type_text"
	NodeTypeKey       = "key"
	NodeTypeDelay     = "delay"
	NodeTypeLaunchApp = "launch_app"
	NodeTypeStopApp   = "stop_app"
	NodeTypeShell     = "shell"
)

// NodeParams contains configuration parameters for any node type
type NodeParams struct {
	// Tap / Click coordinates (normalized 0.0-1.0 or absolute pixels)
	X            float64 `json:"x,omitempty"`
	Y            float64 `json:"y,omitempty"`
	RandomJitter bool    `json:"randomJitter,omitempty"` // Add slight random coordinate deviation

	// Swipe parameters
	Direction string  `json:"direction,omitempty"` // "up", "down", "left", "right", "custom"
	X2        float64 `json:"x2,omitempty"`
	Y2        float64 `json:"y2,omitempty"`

	// Duration and delay (ms)
	DurationMs int `json:"durationMs,omitempty"`
	MinDelayMs int `json:"minDelayMs,omitempty"`
	MaxDelayMs int `json:"maxDelayMs,omitempty"`

	// Text typing
	Text string `json:"text,omitempty"`

	// Key events
	KeyCode   uint32 `json:"keyCode,omitempty"`
	KeyAction string `json:"keyAction,omitempty"` // "home", "back", "app_switch", "power", etc.

	// App management
	PackageName string `json:"packageName,omitempty"`

	// Shell execution
	ShellCmd string `json:"shellCmd,omitempty"`
}

// Node represents an individual action step inside a workflow
type Node struct {
	ID          string     `json:"id"`
	Type        string     `json:"type"`
	Label       string     `json:"label"`
	Description string     `json:"description,omitempty"`
	Params      NodeParams `json:"params"`
	Disabled    bool       `json:"disabled,omitempty"`
}

// Workflow represents a complete automation flow
type Workflow struct {
	ID            string   `json:"id"`
	Name          string   `json:"name"`
	Description   string   `json:"description,omitempty"`
	LoopCount     int      `json:"loopCount,omitempty"` // 1 = run once, -1 = infinite
	LoopDelayMs   int      `json:"loopDelayMs,omitempty"`
	TargetDevices []string `json:"targetDevices,omitempty"` // UDIDs, empty means all online devices
	Nodes         []Node   `json:"nodes"`
	CreatedAt     string   `json:"createdAt,omitempty"`
	UpdatedAt     string   `json:"updatedAt,omitempty"`
}

// EngineStatus describes current runtime state of the workflow engine
type EngineStatus struct {
	IsRunning     bool   `json:"isRunning"`
	WorkflowID    string `json:"workflowId,omitempty"`
	WorkflowName  string `json:"workflowName,omitempty"`
	CurrentStep   int    `json:"currentStep"`
	TotalSteps    int    `json:"totalSteps"`
	CurrentLoop   int    `json:"currentLoop"`
	TotalLoops    int    `json:"totalLoops"`
	CurrentNodeID string `json:"currentNodeId,omitempty"`
	ErrorMessage  string `json:"errorMessage,omitempty"`
}

// ValidateNode checks if required parameters are provided for a node
func ValidateNode(node Node) error {
	if node.ID == "" {
		return errors.New("node ID is required")
	}

	switch node.Type {
	case NodeTypeTap:
		if node.Params.X < 0 || node.Params.Y < 0 {
			return errors.New("tap coordinates must be non-negative")
		}
	case NodeTypeSwipe:
		dir := strings.ToLower(node.Params.Direction)
		if dir == "" {
			dir = "up"
		}
		if dir != "up" && dir != "down" && dir != "left" && dir != "right" && dir != "custom" {
			return errors.New("invalid swipe direction: must be up, down, left, right, or custom")
		}
	case NodeTypeTypeText:
		if strings.TrimSpace(node.Params.Text) == "" {
			return errors.New("type_text node requires non-empty text")
		}
	case NodeTypeLaunchApp:
		if strings.TrimSpace(node.Params.PackageName) == "" {
			return errors.New("launch_app node requires packageName")
		}
	case NodeTypeStopApp:
		if strings.TrimSpace(node.Params.PackageName) == "" {
			return errors.New("stop_app node requires packageName")
		}
	case NodeTypeShell:
		if strings.TrimSpace(node.Params.ShellCmd) == "" {
			return errors.New("shell node requires shellCmd")
		}
	case NodeTypeDelay:
		// Any delay is allowed (>=0)
	case NodeTypeKey:
		// Any key is allowed
	default:
		return errors.New("unknown node type: " + node.Type)
	}

	return nil
}
